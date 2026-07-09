package com.elvencode.productportal.user.address.entity;

import com.elvencode.productportal.common.persistence.BaseEntity;
import com.elvencode.productportal.user.entity.PortalUser;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@Entity
@Table(
        name = "pp_usm_addresses",
        indexes = {
                @Index(name = "idx_pp_usm_addresses_user_id", columnList = "user_id"),
                @Index(name = "idx_pp_usm_addresses_user_default", columnList = "user_id, is_default"),
                @Index(name = "idx_pp_usm_addresses_city", columnList = "city"),
                @Index(name = "idx_pp_usm_addresses_postal_code", columnList = "postal_code")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class Address extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "address_id", nullable = false, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private Long id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_usm_addresses_user"))
    private PortalUser portalUser;

    @NotBlank
    @Size(max = 150)
    @Column(name = "recipient_name", nullable = false, length = 150)
    private String recipientName;

    @NotBlank
    @Size(max = 30)
    @Column(name = "phone_number", nullable = false, length = 30)
    private String phoneNumber;

    @NotBlank
    @Size(max = 255)
    @Column(name = "address_line_1", nullable = false)
    private String addressLine1;

    @Size(max = 255)
    @Column(name = "address_line_2")
    private String addressLine2;

    @NotBlank
    @Size(max = 100)
    @Column(name = "city", nullable = false, length = 100)
    private String city;

    @Size(max = 100)
    @Column(name = "district", length = 100)
    private String district;

    @Size(max = 100)
    @Column(name = "province", length = 100)
    private String province;

    @Size(max = 20)
    @Column(name = "postal_code", length = 20)
    private String postalCode;

    @NotBlank
    @Size(max = 100)
    @Column(name = "country", nullable = false, length = 100)
    private String country;

    @NotNull
    @Column(name = "is_default", nullable = false)
    private Boolean defaultAddress = Boolean.FALSE;

    @Version
    @Column(name = "version", nullable = false)
    private Long version;

    public static Address create(
            PortalUser portalUser,
            String recipientName,
            String phoneNumber,
            String addressLine1,
            String addressLine2,
            String city,
            String district,
            String province,
            String postalCode,
            String country,
            boolean defaultAddress) {
        Address address = new Address();
        address.portalUser = portalUser;
        address.recipientName = recipientName;
        address.phoneNumber = phoneNumber;
        address.addressLine1 = addressLine1;
        address.addressLine2 = addressLine2;
        address.city = city;
        address.district = district;
        address.province = province;
        address.postalCode = postalCode;
        address.country = country;
        address.defaultAddress = defaultAddress;
        return address;
    }
}
