package com.elvencode.productportal.user.repository;

import com.elvencode.productportal.user.dto.response.UserDetailsResponse;
import com.elvencode.productportal.user.entity.PortalUser;
import com.elvencode.productportal.user.reference.entity.UserStatus;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<PortalUser, Long> {

    @EntityGraph(attributePaths = {"role", "status", "addresses"})
    Optional<PortalUser> findPortalUserByUsername(String username);

    @EntityGraph(attributePaths = {"role", "status"})
    Optional<PortalUser> findByUsername(String username);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    boolean existsByPhoneNumber(String phoneNumber);

    @EntityGraph(attributePaths = {"role", "status"})
    List<PortalUser> findAllByStatus(UserStatus status);
    /**
     * Native query to fetch users by status code. Filters out inactive statuses.
     * Returns PortalUser entities mapped from pp_usm_users table. Use with care
     * as native queries do not automatically apply JPA EntityGraphs to eagerly
     * load associations; load associations lazily or fetch via separate queries
     * or service-level aggregation when needed.
     */
    @Query(value = """
            SELECT DISTINCT u.*
            FROM pp_usm_users u
            LEFT JOIN pp_usm_roles r ON u.role_code = r.role_code
            LEFT JOIN pp_usm_addresses a ON u.user_id = a.user_id
            INNER JOIN pp_usr_user_statuses s ON u.status = s.status_code
            WHERE s.status_code = :statusCode
              AND s.is_active = TRUE
            """, nativeQuery = true)
    List<PortalUser> getAllUsersByUserStatus(@Param("statusCode") String statusCode);

    /**
     * JPQL version: returns paginated PortalUser IDs where the associated UserStatus
     * has the given statusCode and is active. Uses EntityGraph to eagerly fetch
     * role and status associations to avoid N+1 queries.
     * Sorting: controlled via Pageable parameter. Default: username DESC.
     */
    @EntityGraph(attributePaths = {"role", "status"})
    @Query("SELECT p.id FROM PortalUser p JOIN p.status s WHERE s.statusCode = :statusCode AND s.active = TRUE")
    Page<Long> findIdsByStatusCode(@Param("statusCode") String statusCode, Pageable pageable);

    @Query("SELECT DISTINCT p FROM PortalUser p LEFT JOIN FETCH p.role LEFT JOIN FETCH p.status LEFT JOIN FETCH p.addresses WHERE p.id IN :ids")
    List<PortalUser> findAllByIdInFetch(@Param("ids") List<Long> ids);

    @Query("SELECT p FROM PortalUser p JOIN p.status s WHERE s.statusCode = :statusCode AND s.active = TRUE")
    List<PortalUser> getAllUsersByUserStatusJPQL(@Param("statusCode") String statusCode);
}
