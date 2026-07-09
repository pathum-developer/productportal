package com.elvencode.productportal.user.service;

import com.elvencode.productportal.user.dto.request.UserRegistrationRequest;
import com.elvencode.productportal.user.dto.response.UserDetailsResponse;
import com.elvencode.productportal.user.dto.response.UserRegistrationResponse;
import jakarta.validation.constraints.NotBlank;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface UserService {

    UserDetailsResponse getUserDetailsByUsername(String username);

    UserRegistrationResponse registerUser(UserRegistrationRequest request);

    Page<UserDetailsResponse> getAllUsersByStatus(@NotBlank(message = "Status is required") String status, Pageable pageable);
}
