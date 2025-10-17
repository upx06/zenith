cd ~/projects/upx06/zenith

# Exporte as variáveis de ambiente
export DATABASE_URL="postgresql://zenith:OwkkhSvoYElYS0itlAjPGF2pbEQrvyQW@dpg-d3onk4vdiees73c3qvtg-a/zenith_db_wcct"
export SECRET_KEY_BASE="EC/0OOWCl040dk8QVGOV3E66bXxxof8aPjl1QaZ7u2Sk2WecpYCdU3aX6LAaKmRu"
export TOKEN_SIGNING_SECRET="BgAT9X0mLVp+6hKAsCKeH5KdGijytBBUYwdl359B2sw="
export PHX_SERVER=true
export PHX_HOST=localhost

# Rode o servidor
mix phx.server
