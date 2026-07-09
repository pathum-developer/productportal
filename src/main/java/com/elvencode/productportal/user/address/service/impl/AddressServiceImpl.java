package com.elvencode.productportal.user.address.service.impl;

import com.elvencode.productportal.common.exception.ResourceNotFoundException;
import com.elvencode.productportal.user.address.dto.request.AddressCreateRequest;
import com.elvencode.productportal.user.address.dto.response.AddressResponse;
import com.elvencode.productportal.user.address.entity.Address;
import com.elvencode.productportal.user.address.mapper.AddressMapper;
import com.elvencode.productportal.user.address.repository.AddressRepository;
import com.elvencode.productportal.user.address.service.AddressService;
import com.elvencode.productportal.user.entity.PortalUser;
import com.elvencode.productportal.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AddressServiceImpl implements AddressService {

    private final AddressRepository addressRepository;
    private final UserRepository userRepository;
    private final AddressMapper addressMapper;

    @Override
    @Transactional
    public AddressResponse createAddressForUser(AddressCreateRequest request, Long userId) {
        PortalUser portalUser = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        boolean firstAddress = !addressRepository.existsByPortalUserId(userId);
        boolean defaultAddress = Boolean.TRUE.equals(request.defaultAddress()) || firstAddress;

        if (defaultAddress) {
            addressRepository.clearDefaultAddressForUser(userId);
        }

        Address address = Address.create(
                portalUser,
                request.recipientName().trim(),
                request.phoneNumber().trim(),
                request.addressLine1().trim(),
                normalizeOptionalText(request.addressLine2()),
                request.city().trim(),
                normalizeOptionalText(request.district()),
                normalizeOptionalText(request.province()),
                normalizeOptionalText(request.postalCode()),
                request.country().trim(),
                defaultAddress);

        return addressMapper.toResponse(addressRepository.save(address));
    }

    @Override
    public List<AddressResponse> getAddressesForUser(Long userId) {
        return addressRepository.findAllByPortalUserIdOrderByDefaultAddressDescIdAsc(userId)
                .stream()
                .map(addressMapper::toResponse)
                .toList();
    }

    @Override
    public AddressResponse getAddressByIdForUser(Long addressId, Long userId) {
        Address address = addressRepository.findByIdAndPortalUserId(addressId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Address", "id", addressId));

        return addressMapper.toResponse(address);
    }

    private String normalizeOptionalText(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }
}
