package com.elvencode.productportal.catalog.product.repository;

import com.elvencode.productportal.catalog.product.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;

public interface ProductRepository extends JpaRepository<Product, Long> {

    @EntityGraph(attributePaths = {"category", "brand", "status"})
    Page<Product> findByCategory_Id(Long categoryId, Pageable pageable);

    @EntityGraph(attributePaths = {"category", "brand", "status"})
    Page<Product> findByCategory_IdIn(Collection<Long> categoryIds, Pageable pageable);
}
