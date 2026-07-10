package com.elvencode.productportal.organization.membership.entity;

import com.elvencode.productportal.common.persistence.BaseEntity;
import com.elvencode.productportal.organization.entity.Organization;
import com.elvencode.productportal.organization.reference.entity.MembershipStatus;
import com.elvencode.productportal.user.entity.PortalUser;
import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(
        name = "pp_t_user_organization_membership",
        indexes = {
                @Index(name = "idx_pp_t_user_organization_membership_status", columnList = "membership_status"),
                @Index(
                        name = "idx_pp_t_user_organization_membership_org_status",
                        columnList = "organization_id, membership_status"),
                @Index(
                        name = "idx_pp_t_user_organization_membership_user_status",
                        columnList = "user_id, membership_status"),
                @Index(name = "idx_pp_t_user_organization_membership_primary", columnList = "user_id, is_primary"),
                @Index(name = "idx_pp_t_user_organization_membership_invited_by", columnList = "invited_by")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class UserOrganizationMembership extends BaseEntity {

    @EmbeddedId
    @EqualsAndHashCode.Include
    private UserOrganizationMembershipId id = new UserOrganizationMembershipId();

    @NotNull
    @MapsId("userId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_t_user_organization_membership_user"))
    private PortalUser user;

    @NotNull
    @MapsId("organizationId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "organization_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_t_user_organization_membership_organization"))
    private Organization organization;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "membership_status",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_t_user_organization_membership_status"))
    private MembershipStatus membershipStatus;

    @NotNull
    @Column(name = "is_primary", nullable = false)
    private Boolean primaryMembership = Boolean.FALSE;

    @Column(name = "joined_at")
    private Instant joinedAt;

    @Size(max = 100)
    @Column(name = "invited_by", length = 100)
    private String invitedBy;

    @Column(name = "invited_at")
    private Instant invitedAt;

    public static UserOrganizationMembership primaryMembership(
            PortalUser user,
            Organization organization,
            MembershipStatus membershipStatus,
            Instant joinedAt) {
        UserOrganizationMembership membership = new UserOrganizationMembership();
        membership.id = new UserOrganizationMembershipId(user.getId(), organization.getId());
        membership.user = user;
        membership.organization = organization;
        membership.membershipStatus = membershipStatus;
        membership.primaryMembership = Boolean.TRUE;
        membership.joinedAt = joinedAt;
        return membership;
    }

    public boolean isActiveMembership() {
        return membershipStatus != null
                && Boolean.TRUE.equals(membershipStatus.getActive())
                && "ACTIVE".equals(membershipStatus.getStatusCode());
    }
}
