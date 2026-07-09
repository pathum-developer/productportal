package com.elvencode.productportal.user.service.impl;

import com.elvencode.productportal.access.role.entity.Role;
import com.elvencode.productportal.access.role.repository.RoleRepository;
import com.elvencode.productportal.common.exception.ResourceConflictException;
import com.elvencode.productportal.common.exception.ResourceNotFoundException;
import com.elvencode.productportal.user.dto.request.UserRegistrationRequest;
import com.elvencode.productportal.user.entity.PortalUser;
import com.elvencode.productportal.user.dto.response.UserDetailsResponse;
import com.elvencode.productportal.user.dto.response.UserRegistrationResponse;
import com.elvencode.productportal.user.mapper.UserMapper;
import com.elvencode.productportal.user.reference.entity.UserStatus;
import com.elvencode.productportal.user.reference.repository.UserStatusRepository;
import com.elvencode.productportal.user.repository.UserRepository;
import com.elvencode.productportal.user.service.UserService;
import com.elvencode.productportal.user.util.SortValidator;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserServiceImpl implements UserService {

    private static final String DEFAULT_REGISTRATION_ROLE_CODE = "BUYER";
    private static final String DEFAULT_REGISTRATION_STATUS_CODE = "ACTIVE";

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final UserStatusRepository userStatusRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;

    @Override
    public UserDetailsResponse getUserDetailsByUsername(String username) {

        String normalizedUsername = username.trim().toLowerCase(Locale.ROOT);

        PortalUser portalUser = userRepository.findPortalUserByUsername(normalizedUsername)
                .orElseThrow(() -> new ResourceNotFoundException("User", "username", username));

        return userMapper.toDetailsResponse(portalUser);
    }

    @Override
    @Transactional
    public UserRegistrationResponse registerUser(UserRegistrationRequest request) {
        String username = normalizeUsername(request.username());
        String email = normalizeEmail(request.email());
        String fullName = request.fullName().trim();
        String phoneNumber = normalizeOptionalText(request.phoneNumber());

        validateUniqueRegistrationData(username, email, phoneNumber);

        Role role = roleRepository.findById(DEFAULT_REGISTRATION_ROLE_CODE)
                .filter(value -> Boolean.TRUE.equals(value.getActive()))
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Role", "code", DEFAULT_REGISTRATION_ROLE_CODE));

        UserStatus status = userStatusRepository.findById(DEFAULT_REGISTRATION_STATUS_CODE)
                .filter(value -> Boolean.TRUE.equals(value.getActive()))
                .orElseThrow(() -> new ResourceNotFoundException(
                        "UserStatus", "code", DEFAULT_REGISTRATION_STATUS_CODE));

        PortalUser portalUser = PortalUser.register(
                username,
                fullName,
                email,
                phoneNumber,
                passwordEncoder.encode(request.password()),
                role,
                status);

        try {
            PortalUser savedUser = userRepository.saveAndFlush(portalUser);
            return userMapper.toRegistrationResponse(savedUser);
        } catch (DataIntegrityViolationException exception) {
            throw new ResourceConflictException("User", "registration data", username);
        }
    }

    @Override
    public Page<UserDetailsResponse> getAllUsersByStatus(String status, Pageable pageable) {
        String normalizedStatus = status.trim().toUpperCase(Locale.ROOT);

        // Validate and sanitize sort parameters to prevent SQL injection
        Pageable validatedPageable = SortValidator.validateAndSanitizeSort(pageable);

        // 1) fetch matching user ids (paged with validated sort)
        Page<Long> idPage = userRepository.findIdsByStatusCode(normalizedStatus, validatedPageable);

        if (idPage.isEmpty()) {
            return Page.empty(validatedPageable);
        }

        List<Long> ids = idPage.getContent();

        // 2) fetch entities + associations for those ids in a single fetch-join
        List<PortalUser> users = userRepository.findAllByIdInFetch(ids);

        // preserve original id ordering
        var userById = users.stream().collect(Collectors.toMap(PortalUser::getId, u -> u));

        List<UserDetailsResponse> dtos = ids.stream()
                .map(id -> userMapper.toDetailsResponse(userById.get(id)))
                .toList();

        return new PageImpl<>(dtos, validatedPageable, idPage.getTotalElements());
    }


    private void validateUniqueRegistrationData(String username, String email, String phoneNumber) {
        if (userRepository.existsByUsername(username)) {
            throw new ResourceConflictException("User", "username", username);
        }

        if (userRepository.existsByEmail(email)) {
            throw new ResourceConflictException("User", "email", email);
        }

        if (phoneNumber != null && userRepository.existsByPhoneNumber(phoneNumber)) {
            throw new ResourceConflictException("User", "phone number", phoneNumber);
        }
    }

    private String normalizeUsername(String username) {
        return username.trim().toLowerCase(Locale.ROOT);
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private String normalizeOptionalText(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

}

