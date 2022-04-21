include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts_asuscomm
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

PKG_LICENSE:=GPLv2
PKG_MAINTAINER:=XuHaojie <xuhaojie@hotmail.com>

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=IP Addresses and Names
	TITLE:=Extension for asuscomm.com (require curl)
	PKGARCH:=all
	DEPENDS:=+ddns-scripts +curl +openssl-util
endef

define Package/$(PKG_NAME)/description
	Dynamic DNS Client scripts extension for asuscomm.com (require curl)
	It requires:
	option username - mac address registered to asuscomm.com, for example AA:BB:CC:DD:EE:FF:12
	option password - wps pin, eight digits wps pin for example 123456
	option domain   - domain registered to asuscomm.com, for example user.asuscomm.com
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./update_asuscomm_com.sh $(1)/usr/lib/ddns

	$(INSTALL_DIR) $(1)/usr/share/ddns/default
	$(INSTALL_DATA) ./asuscomm.com.json $(1)/usr/share/ddns/default
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns stop
fi

exit 0
endef

define Package/$(PKG_NAME)/postinst
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/ddns enabled
	/etc/init.d/ddns start
fi
exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
