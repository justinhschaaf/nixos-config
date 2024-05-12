{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.loki.enable = lib.mkEnableOption "Loki, like Prometheus, but for logs. ";
        js.server.loki.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    # Most of this is from https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
    # All of it is documented at https://grafana.com/docs/loki/latest/configure/
    config = lib.mkIf config.js.server.loki.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.loki.openFirewall [ config.services.loki.configuration.server.http_listen_port ];

        services.loki.enable = true;
        services.loki.configuration = {
        
            auth_enabled = false;
            server.http_listen_port = 3100; # default

            ingester.lifecycler = {
                address = "0.0.0.0";
                final_sleep = "0s";
                ring = {
                    kvstore.store = "inmemory";
                    replication_factor = 1;
                };
            };
            
            ingester = {
                chunk_idle_period = "1h";        # flush chunks that aren't doing anything'
                max_chunk_age = "1h";            # flush all old chunks
                chunk_target_size = 1048576;     # build chunks up to 1.5 MB if it isn't already flushed'
                chunk_retain_period = "30s";
            };

            schema_config.configs = [{
                from = "2024-01-19";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                    prefix = "index_";
                    period = "24h";
                };
            }];

            # TSDB is recommended over the older BoltDB https://grafana.com/docs/loki/latest/operations/storage/tsdb/
            storage_config.filesystem.directory = "${config.services.loki.dataDir}/chunks";
            storage_config.tsdb_shipper = {
                active_index_directory = "${config.services.loki.dataDir}/tsdb-active";
                cache_location = "${config.services.loki.dataDir}/tsdb-cache";
            };

            compactor = {
                working_directory = "${config.services.loki.dataDir}/compactor";
                compactor_ring.kvstore.store = "inmemory";
            };
            
        };

        services.promtail.enable = true;
        services.promtail.configuration = {

            # set random listen ports, we don't give a shit about these
            server = {
                http_listen_port = 0;
                grpc_listen_port = 0;
            };

            clients = [{ url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"; }];

            scrape_configs = [{
            
                job_name = "journal";
                
                journal.max_age = "12h";
                journal.labels = {
                    job = "systemd-journal";
                    host = config.networking.hostName;
                };

                relabel_configs = [{
                    source_labels = [ "__journal__systemd_unit" ];
                    target_label = "unit";
                }];
                
            }];
        
        };
    
    };

}

