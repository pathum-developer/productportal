package com.elvencode.productportal.user.address.mapper;

import com.elvencode.productportal.user.address.dto.response.AddressResponse;
import com.elvencode.productportal.user.address.entity.Address;
import org.springframework.stereotype.Component;

@Component
public class AddressMapper {

    public AddressResponse toResponse(Address address) {
        return new AddressResponse(
                address.getId(),
                address.getRecipientName(),
                address.getPhoneNumber(),
                address.getAddressLine1(),
                address.getAddressLine2(),
                address.getCity(),
                address.getDistrict(),
                address.getProvince(),
                address.getPostalCode(),
                address.getCountry(),
                address.getDefaultAddress(),
                address.getVersion(),
                address.getCreatedAt(),
                address.getCreatedBy(),
                address.getUpdatedAt(),
                address.getUpdatedBy());
    }
}
