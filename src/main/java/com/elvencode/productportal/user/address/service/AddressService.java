package com.elvencode.productportal.user.address.service;

import com.elvencode.productportal.user.address.dto.request.AddressCreateRequest;
import com.elvencode.productportal.user.address.dto.response.AddressResponse;

import java.util.List;

public interface AddressService {

    AddressResponse createAddressForUser(AddressCreateRequest request, Long userId);

    List<AddressResponse> getAddressesForUser(Long userId);

    AddressResponse getAddressByIdForUser(Long addressId, Long userId);
}
