package com.elvencode.productportal.user.reference.repository;

import com.elvencode.productportal.user.reference.entity.UserStatus;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserStatusRepository extends JpaRepository<UserStatus, String> {
}
