
## Setup

Requires cron, mutt, git, zip

```bash
nix-env -iA nixos.mutt nixos.zip nixos.python310
```

## Mutt

example `.muttrc`
```
set my_pass='<pass>'
set my_user=user@fastmail.com

set realname = 'Kokkos Kernels Nightly'
set from = kk-builder@example.com
set use_from = yes

set smtp_pass = $my_pass
set smtp_url=smtps://$my_user@smtp.fastmail.com
set ssl_force_tls = yes
set ssl_starttls = yes
```

Soft-link .muttrc to ~/.muttrc

