package com.elvencode.productportal.user.entity;

import com.elvencode.productportal.access.role.entity.Role;
import com.elvencode.productportal.common.persistence.BaseEntity;
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

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(
        name = "pp_usm_users",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_pp_usm_users_username", columnNames = "username"),
                @UniqueConstraint(name = "uk_pp_usm_users_email", columnNames = "email"),
                @UniqueConstraint(name = "uk_pp_usm_users_phone_number", columnNames = "phone_number")
        },
        indexes = {
                @Index(name = "idx_pp_usm_users_role_code", columnList = "role_code"),
                @Index(name = "idx_pp_usm_users_status", columnList = "status"),
                @Index(name = "idx_pp_usm_users_role_status", columnList = "role_code, status")
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
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "role_code",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_usm_users_role"))
    private Role role;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "status",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_usm_users_status"))
    private UserStatus status;

    @OrderBy("defaultAddress DESC, id ASC")
    @OneToMany(mappedBy = "portalUser", cascade = CascadeType.ALL, orphanRemoval = true)
    @BatchSize(size = 5)
    private List<Address> addresses = new ArrayList<>();

    @Version
    @Column(name = "version", nullable = false)
    private Long version;

    public static PortalUser register(
            String username,
            String fullName,
            String email,
            String phoneNumber,
            String passwordHash,
            Role role,
            UserStatus status) {
        PortalUser portalUser = new PortalUser();
        portalUser.username = username;
        portalUser.fullName = fullName;
        portalUser.email = email;
        portalUser.phoneNumber = phoneNumber;
        portalUser.passwordHash = passwordHash;
        portalUser.role = role;
        portalUser.status = status;
        return portalUser;
    }
}
