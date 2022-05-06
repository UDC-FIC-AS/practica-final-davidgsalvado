{application,emailservice,
             [{applications,[kernel,stdlib,elixir,logger]},
              {description,"emailservice"},
              {modules,['Elixir.Client','Elixir.Db','Elixir.Directory',
                        'Elixir.Emailservice',
                        'Elixir.Emailservice.Application',
                        'Elixir.LoadBalancer','Elixir.MXConfig',
                        'Elixir.MessageService','Elixir.NodeManager',
                        'Elixir.ServerDb','Elixir.ServiceResponseSender',
                        'Elixir.UserDb','Elixir.UserService']},
              {registered,[]},
              {vsn,"0.1.0"},
              {mod,{'Elixir.Emailservice.Application',[]}}]}.