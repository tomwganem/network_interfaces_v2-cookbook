#
# Author:: Jacob McCann (<jacob.mccann2@target.com>)
# Cookbook Name:: network_interfaces_v2
# Provider:: debian_network_interface
#
# Copyright:: 2015, Target Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider/lwrp_base'
require_relative 'provider_network_interface'

class Chef
  class Provider
    class NetworkInterface
      #
      # Chef Provider for Debian Network Interfaces
      #
      class Debian < Chef::Provider::NetworkInterface
        provides :debian_network_interface, os: 'linux', platform_family: %w(debian) if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12.0.0')

        def action_create # rubocop:disable MethodLength
          run_context.include_recipe 'network_interfaces_v2::_debian'

          template "/etc/network/interfaces.d/#{new_resource.device}" do
            cookbook new_resource.cookbook
            source new_resource.source
            mode 0644
            variables device: new_resource.device,
                      type: new_resource.type,
                      auto: new_resource.onboot,
                      address: new_resource.address,
                      netmask: new_resource.netmask,
                      gateway: new_resource.gateway,
                      broadcast: new_resource.broadcast,
                      bridge_ports: new_resource.bridge_ports,
                      bridge_stp: new_resource.bridge_stp,
                      vlan_dev: new_resource.vlan,
                      bond_master: new_resource.bond_master,
                      bond_slaves: new_resource.bond_slaves,
                      bond_mode: new_resource.bond_mode,
                      mtu: new_resource.mtu,
                      metric: new_resource.metric,
                      pre_up: new_resource.pre_up,
                      up: new_resource.up,
                      post_up: new_resource.post_up,
                      pre_down: new_resource.pre_down,
                      down: new_resource.down,
                      post_down: new_resource.post_down,
                      custom: new_resource.custom
            notifies :run, "execute[reload interface #{new_resource.device}]", new_resource.reload_type if new_resource.reload
          end

          execute "reload interface #{new_resource.device}" do
            command <<-EOF
              ifdown #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}
              ifup #{new_resource.device} -i /etc/network/interfaces.d/#{new_resource.device}
            EOF
            action :nothing
          end
        end
      end
    end
  end
end
