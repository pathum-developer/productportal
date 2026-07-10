package com.elvencode.productportal.organization.entity;

import com.elvencode.productportal.common.persistence.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import jakarta.persistence.Version;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.NaturalId;

@Getter
@Setter
@Entity
@Table(
        name = "pp_m_organization",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_pp_m_organization_code", columnNames = "organization_code"),
                @UniqueConstraint(name = "uk_pp_m_organization_display_name", columnNames = "display_name")
        },
        indexes = {
                @Index(name = "idx_pp_m_organization_active", columnList = "is_active")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class Organization extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "organization_id", nullable = false, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private Long id;

    @NaturalId(mutable = true)
    @NotBlank
    @Size(max = 60)
    @Column(name = "organization_code", nullable = false, length = 60)
    @ToString.Include
    private String organizationCode;

    @NotBlank
    @Size(max = 150)
    @Column(name = "display_name", nullable = false, length = 150)
    @ToString.Include
    private String displayName;

    @Size(max = 200)
    @Column(name = "legal_name", length = 200)
    private String legalName;

    @Size(max = 255)
    @Column(name = "description", length = 255)
    private String description;

    @NotNull
    @Column(name = "is_active", nullable = false)
    private Boolean active = Boolean.TRUE;

    @Version
    @Column(name = "version", nullable = false)
    private Long version;
}
