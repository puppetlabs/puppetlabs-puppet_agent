type Puppet_agent::Config = Variant[Struct[{section          => Enum[main, server, agent, user, master],
                                            setting          => Puppet_agent::Config_setting,
                                            value            => String,
                                            Optional[ensure] => Enum[present, absent]}],
                                    Struct[{section          => Enum[main, server, agent, user, master],
                                            setting          => Puppet_agent::Config_setting,
                                            Optional[ensure] => Enum[absent]}]]
