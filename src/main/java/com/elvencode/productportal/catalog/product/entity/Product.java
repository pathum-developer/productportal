package com.elvencode.productportal.catalog.product.entity;

import com.elvencode.productportal.catalog.brand.entity.Brand;
import com.elvencode.productportal.catalog.category.entity.Category;
import com.elvencode.productportal.catalog.reference.entity.ProductStatus;
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
        name = "pp_m_products",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_pp_m_products_slug", columnNames = "slug"),
                @UniqueConstraint(name = "uk_pp_m_products_sku_code", columnNames = "sku_code")
        },
        indexes = {
                @Index(name = "idx_pp_m_products_category_id", columnList = "category_id"),
                @Index(name = "idx_pp_m_products_brand_id", columnList = "brand_id"),
                @Index(name = "idx_pp_m_products_status", columnList = "status_code"),
                @Index(
                        name = "idx_pp_m_products_category_status",
                        columnList = "category_id, status_code"),
                @Index(
                        name = "idx_pp_m_products_brand_status",
                        columnList = "brand_id, status_code")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class Product extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id", nullable = false, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private Long id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "category_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_m_products_category"))
    private Category category;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "brand_id",
            foreignKey = @ForeignKey(name = "fk_pp_m_products_brand"))
    private Brand brand;

    @NotBlank
    @Size(max = 255)
    @Column(name = "name", nullable = false, length = 255)
    @ToString.Include
    private String name;

    @NaturalId(mutable = true)
    @NotBlank
    @Size(max = 300)
    @Column(name = "slug", nullable = false, length = 300)
    @ToString.Include
    private String slug;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Size(max = 100)
    @Column(name = "model_number", length = 100)
    private String modelNumber;

    @Size(max = 100)
    @Column(name = "sku_code", length = 100)
    private String skuCode;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "status_code",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_m_products_status"))
    private ProductStatus status;

    @Version
    @Column(name = "version", nullable = false)
    private Long version;
}
