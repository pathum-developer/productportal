package com.elvencode.productportal.catalog.category.entity;

import com.elvencode.productportal.catalog.product.entity.Product;
import com.elvencode.productportal.catalog.reference.entity.CategoryStatus;
import com.elvencode.productportal.common.persistence.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.NaturalId;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(
        name = "pp_m_categories",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_pp_m_categories_slug", columnNames = "slug")
        },
        indexes = {
                @Index(name = "idx_pp_m_categories_parent_id", columnList = "parent_category_id"),
                @Index(name = "idx_pp_m_categories_status", columnList = "status_code"),
                @Index(
                        name = "idx_pp_m_categories_parent_status",
                        columnList = "parent_category_id, status_code")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class Category extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id", nullable = false, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "parent_category_id",
            foreignKey = @ForeignKey(name = "fk_pp_m_categories_parent"))
    private Category parentCategory;

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

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "status_code",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_m_categories_status"))
    private CategoryStatus status;

    @NotNull
    @PositiveOrZero
    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    @Version
    @Column(name = "version", nullable = false)
    private Long version;

}
