package com.elvencode.productportal.security.service;

import com.elvencode.productportal.security.authentication.ProductPortalAuthenticationContext;
import com.elvencode.productportal.user.entity.PortalUser;

public interface CurrentUserAccessService {

    ProductPortalAuthenticationContext loadContextByUserId(Long userId);

    ProductPortalAuthenticationContext buildContext(PortalUser portalUser);
}
