package com.elvencode.productportal.user.address.repository;

import com.elvencode.productportal.user.address.entity.Address;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface AddressRepository extends JpaRepository<Address, Long> {

    List<Address> findAllByPortalUserIdOrderByDefaultAddressDescIdAsc(Long userId);

    Optional<Address> findByIdAndPortalUserId(Long id, Long userId);

    boolean existsByPortalUserId(Long userId);

    @Modifying
    @Query("""
            update Address address
            set address.defaultAddress = false
            where address.portalUser.id = :userId
              and address.defaultAddress = true
            """)
    void clearDefaultAddressForUser(@Param("userId") Long userId);
}
