package com.elvencode.productportal.user.entity;

import com.elvencode.productportal.access.assignment.entity.UserRoleAssignment;
import com.elvencode.productportal.access.role.entity.Role;
import com.elvencode.productportal.common.persistence.BaseEntity;
import com.elvencode.productportal.organization.entity.Organization;
import com.elvencode.productportal.organization.membership.entity.UserOrganizationMembership;
import com.elvencode.productportal.user.address.entity.Address;
import com.elvencode.productportal.user.reference.entity.UserStatus;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import jakarta.persistence.Version;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.NaturalId;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(
        name = "pp_m_user",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_pp_m_user_username", columnNames = "username"),
                @UniqueConstraint(name = "uk_pp_m_user_email", columnNames = "email"),
                @UniqueConstraint(name = "uk_pp_m_user_phone_number", columnNames = "phone_number")
        },
        indexes = {
                @Index(name = "idx_pp_m_user_status", columnList = "status"),
                @Index(name = "idx_pp_m_user_primary_organization_id", columnList = "primary_organization_id")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class PortalUser extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id", nullable = false, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private Long id;

    @NaturalId(mutable = true)
    @NotBlank
    @Size(max = 100)
    @Column(name = "username", nullable = false, length = 100)
    @ToString.Include
    private String username;

    @NotBlank
    @Size(max = 150)
    @Column(name = "full_name", nullable = false, length = 150)
    @ToString.Include
    private String fullName;

    @Email
    @NotBlank
    @Size(max = 254)
    @Column(name = "email", nullable = false, length = 254)
    private String email;

    @Size(max = 30)
    @Column(name = "phone_number", length = 30)
    private String phoneNumber;

    @NotBlank
    @Size(max = 255)
    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @NotNull
    @Column(name = "credentials_changed_at", nullable = false)
    private Instant credentialsChangedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "primary_organization_id",
            foreignKey = @ForeignKey(name = "fk_pp_m_user_primary_organization"))
    private Organization primaryOrganization;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "status",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_m_user_status"))
    private UserStatus status;

    @OrderBy("defaultAddress DESC, id ASC")
    @OneToMany(mappedBy = "portalUser", cascade = CascadeType.ALL, orphanRemoval = true)
    @BatchSize(size = 5)
    private List<Address> addresses = new ArrayList<>();

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    @BatchSize(size = 20)
    private Set<UserOrganizationMembership> memberships = new LinkedHashSet<>();

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    @BatchSize(size = 20)
    private Set<UserRoleAssignment> roleAssignments = new LinkedHashSet<>();

    @Version
    @Column(name = "version", nullable = false)
    private Long version;

    public static PortalUser register(
            String username,
            String fullName,
            String email,
            String phoneNumber,
            String passwordHash,
            UserStatus status,
            Organization primaryOrganization) {
        PortalUser portalUser = new PortalUser();
        portalUser.username = username;
        portalUser.fullName = fullName;
        portalUser.email = email;
        portalUser.phoneNumber = phoneNumber;
        portalUser.passwordHash = passwordHash;
        portalUser.credentialsChangedAt = Instant.now();
        portalUser.status = status;
        portalUser.primaryOrganization = primaryOrganization;
        return portalUser;
    }

    public List<Role> getRoles() {
        return getActiveRoleAssignments()
                .stream()
                .map(UserRoleAssignment::getRole)
                .distinct()
                .toList();
    }

    public List<UserRoleAssignment> getActiveRoleAssignments() {
        Instant now = Instant.now();
        return roleAssignments.stream()
                .filter(assignment -> assignment.isCurrentlyActive(now))
                .sorted(Comparator
                        .comparing((UserRoleAssignment assignment) -> assignment.getRole().getSortOrder())
                        .thenComparing(assignment -> assignment.getRole().getRoleCode()))
                .toList();
    }

    public void addMembership(UserOrganizationMembership membership) {
        memberships.add(membership);
        membership.setUser(this);
    }

    public void addRoleAssignment(UserRoleAssignment roleAssignment) {
        roleAssignments.add(roleAssignment);
        roleAssignment.setUser(this);
    }

    public void setPasswordHash(String passwordHash) {
        changePasswordHash(passwordHash, Instant.now());
    }

    public void changePasswordHash(String passwordHash, Instant changedAt) {
        this.passwordHash = passwordHash;
        this.credentialsChangedAt = changedAt;
    }
}
