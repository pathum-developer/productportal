package com.elvencode.productportal.catalog.category.repository;

import com.elvencode.productportal.catalog.category.entity.Category;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CategoryRepository extends JpaRepository<Category, Long> {

    @EntityGraph(attributePaths = {"parentCategory", "status"})
    Optional<Category> findWithParentCategoryAndStatusById(Long id);

    /*
     * Uses the current adjacency-list model in pp_m_categories.
     * The result includes the requested category itself plus all descendants.
     * The path guard prevents repeated traversal if invalid cyclic hierarchy data exists.
     */
    @Query(value = """
            WITH RECURSIVE category_tree (category_id, path) AS (
                SELECT
                    category_id,
                    CAST(category_id AS CHAR(4000)) AS path
                FROM pp_m_categories
                WHERE category_id = :categoryId

                UNION ALL

                SELECT
                    category.category_id,
                    CONCAT(tree.path, ',', category.category_id)
                FROM pp_m_categories category
                INNER JOIN category_tree tree
                    ON category.parent_category_id = tree.category_id
                WHERE FIND_IN_SET(category.category_id, tree.path) = 0
            )
            SELECT category_id
            FROM category_tree
            """, nativeQuery = true)
    List<Long> findSelfAndDescendantCategoryIds(@Param("categoryId") Long categoryId);
}
