// tldr;
// - Default egress to 0.0.0.0/0 to talk to SCADA
//
// - Servers can talk to other Servers on tcp/8300, tcp/8301, udp/8301, tcp/8302, udp/8302
// - Servers can talk to Clients on tcp/8301, udp/8301
//
// - Clients can talk to Servers on tcp/8300, tcp/8301, udp/8301
// - Clients can talk to other Clients on tcp/8301, udp/8301
//

//
// Default Egress
//
resource "aws_security_group" "default_egress" {
  name        = "default_egress"
  description = "Default Egress"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "default_egress" {
  security_group_id = "${aws_security_group.default_egress.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

//
// Administrative Access
//
resource "aws_security_group" "admin_access" {
  name        = "admin_access"
  description = "Admin Access"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "admin_ssh" {
  security_group_id = "${aws_security_group.admin_access.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}

//
// Consul Client
// - required for Consul Clients
//
resource "aws_security_group" "consul_client" {
  name        = "consul_client"
  description = "Consul Client Access (from servers and other clients)"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "consul_client_serf_lan_tcp_self" {
  security_group_id = "${aws_security_group.consul_client.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8301
  to_port           = 8301
  self              = true
}

resource "aws_security_group_rule" "consul_client_serf_lan_udp_self" {
  security_group_id = "${aws_security_group.consul_client.id}"
  type              = "ingress"
  protocol          = "udp"
  from_port         = 8301
  to_port           = 8301
  self              = true
}

// These next 2 are for consul server access to the clients.
resource "aws_security_group_rule" "consul_client_serf_lan_tcp_consul" {
  security_group_id        = "${aws_security_group.consul_client.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8301
  to_port                  = 8301
  source_security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_client_serf_lan_udp_consul" {
  security_group_id        = "${aws_security_group.consul_client.id}"
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8301
  to_port                  = 8301
  source_security_group_id = "${aws_security_group.consul.id}"
}

//
// Consul LAN Access
// - required for Consul Servers
//
resource "aws_security_group" "consul" {
  name        = "consul"
  description = "Consul Server LAN Access (from other servers and clients)"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "consul_server_rpc_tcp_self" {
  security_group_id = "${aws_security_group.consul.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8300
  to_port           = 8300
  self              = true
}

resource "aws_security_group_rule" "consul_serf_lan_tcp_self" {
  security_group_id = "${aws_security_group.consul.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8301
  to_port           = 8301
  self              = true
}

resource "aws_security_group_rule" "consul_serf_lan_udp_self" {
  security_group_id = "${aws_security_group.consul.id}"
  type              = "ingress"
  protocol          = "udp"
  from_port         = 8301
  to_port           = 8301
  self              = true
}

resource "aws_security_group_rule" "consul_serf_wan_tcp_self" {
  security_group_id = "${aws_security_group.consul.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8302
  to_port           = 8302
  self              = true
}

resource "aws_security_group_rule" "consul_serf_wan_udp_self" {
  security_group_id = "${aws_security_group.consul.id}"
  type              = "ingress"
  protocol          = "udp"
  from_port         = 8302
  to_port           = 8302
  self              = true
}

// These next 3 are for consul_client access to servers.
resource "aws_security_group_rule" "consul_server_rpc_tcp_consul_client" {
  security_group_id        = "${aws_security_group.consul.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8300
  to_port                  = 8300
  source_security_group_id = "${aws_security_group.consul_client.id}"
}

resource "aws_security_group_rule" "consul_serf_lan_tcp_consul_client" {
  security_group_id        = "${aws_security_group.consul.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8301
  to_port                  = 8301
  source_security_group_id = "${aws_security_group.consul_client.id}"
}

resource "aws_security_group_rule" "consul_serf_lan_udp_consul_client" {
  security_group_id        = "${aws_security_group.consul.id}"
  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8301
  to_port                  = 8301
  source_security_group_id = "${aws_security_group.consul_client.id}"
}
