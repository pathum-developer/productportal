package com.elvencode.productportal.catalog.brand.entity;

import com.elvencode.productportal.catalog.reference.entity.BrandStatus;
import com.elvencode.productportal.common.persistence.BaseEntity;
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
        name = "pp_m_brands",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_pp_m_brands_name", columnNames = "name"),
                @UniqueConstraint(name = "uk_pp_m_brands_slug", columnNames = "slug")
        },
        indexes = {
                @Index(name = "idx_pp_m_brands_status", columnList = "status_code")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class Brand extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "brand_id", nullable = false, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private Long id;

    @NotBlank
    @Size(max = 150)
    @Column(name = "name", nullable = false, length = 150)
    @ToString.Include
    private String name;

    @NaturalId(mutable = true)
    @NotBlank
    @Size(max = 180)
    @Column(name = "slug", nullable = false, length = 180)
    @ToString.Include
    private String slug;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Size(max = 500)
    @Column(name = "logo_url", length = 500)
    private String logoUrl;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "status_code",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_m_brands_status"))
    private BrandStatus status;

    @Version
    @Column(name = "version", nullable = false)
    private Long version;
}
