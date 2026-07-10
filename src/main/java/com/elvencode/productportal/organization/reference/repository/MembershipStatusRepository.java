package com.elvencode.productportal.organization.reference.repository;

import com.elvencode.productportal.organization.reference.entity.MembershipStatus;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MembershipStatusRepository extends JpaRepository<MembershipStatus, String> {
}
