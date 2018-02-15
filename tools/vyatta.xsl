<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" encoding="UTF-8"/>

<xsl:template match="/">
set vpn ipsec ike-group AWS lifetime '28800'
set vpn ipsec ike-group AWS proposal 1 dh-group '2'
set vpn ipsec ike-group AWS proposal 1 encryption 'aes128'
set vpn ipsec ike-group AWS proposal 1 hash 'sha1'
set vpn ipsec ike-group AWS dead-peer-detection action 'restart'
set vpn ipsec ike-group AWS dead-peer-detection interval '15'
set vpn ipsec ike-group AWS dead-peer-detection timeout '30'
set vpn ipsec esp-group AWS compression 'disable'
set vpn ipsec esp-group AWS lifetime '3600'
set vpn ipsec esp-group AWS mode 'tunnel'
set vpn ipsec esp-group AWS pfs 'enable'
set vpn ipsec esp-group AWS proposal 1 encryption 'aes128'
set vpn ipsec esp-group AWS proposal 1 hash 'sha1'
set vpn ipsec ipsec-interfaces interface 'eth0'
<xsl:apply-templates select="//vpn_connection/ipsec_tunnel"/>
</xsl:template>
<xsl:template match="ipsec_tunnel">
set vpn ipsec site-to-site peer <xsl:value-of select="vpn_gateway/tunnel_outside_address/ip_address"/> authentication mode 'pre-shared-secret'
set vpn ipsec site-to-site peer <xsl:value-of select="vpn_gateway/tunnel_outside_address/ip_address"/> authentication pre-shared-secret <xsl:value-of select="ike/pre_shared_key"/>
set vpn ipsec site-to-site peer <xsl:value-of select="vpn_gateway/tunnel_outside_address/ip_address"/> ike-group 'AWS'
set vpn ipsec site-to-site peer <xsl:value-of select="vpn_gateway/tunnel_outside_address/ip_address"/> local-address <xsl:value-of select="customer_gateway/tunnel_outside_address/ip_address"/>
set vpn ipsec site-to-site peer <xsl:value-of select="vpn_gateway/tunnel_outside_address/ip_address"/> vti bind 'vti<xsl:value-of select="position()-1"/>'
set vpn ipsec site-to-site peer <xsl:value-of select="vpn_gateway/tunnel_outside_address/ip_address"/> vti esp-group 'AWS'
set interfaces vti vti<xsl:value-of select="position()-1"/> address '<xsl:value-of select="customer_gateway/tunnel_inside_address/ip_address"/>/<xsl:value-of select="customer_gateway/tunnel_inside_address/network_cidr"/>'
set interfaces vti vti<xsl:value-of select="position()-1"/> mtu '1390'

set protocols bgp <xsl:value-of select="customer_gateway/bgp/asn"/> neighbor <xsl:value-of select="vpn_gateway/tunnel_inside_address/ip_address"/> remote-as '<xsl:value-of select="vpn_gateway/bgp/asn"/>'
set protocols bgp <xsl:value-of select="customer_gateway/bgp/asn"/> neighbor <xsl:value-of select="vpn_gateway/tunnel_inside_address/ip_address"/> soft-reconfiguration 'inbound'
set protocols bgp <xsl:value-of select="customer_gateway/bgp/asn"/> neighbor <xsl:value-of select="vpn_gateway/tunnel_inside_address/ip_address"/> timers holdtime '30'
set protocols bgp <xsl:value-of select="customer_gateway/bgp/asn"/> neighbor <xsl:value-of select="vpn_gateway/tunnel_inside_address/ip_address"/> timers keepalive '30'
set protocols bgp <xsl:value-of select="customer_gateway/bgp/asn"/> network 0.0.0.0/0
</xsl:template>
</xsl:stylesheet>
