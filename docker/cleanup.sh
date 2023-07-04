docker rm -fv isvawrprp1
docker rm -fv isvadsc
docker rm -fv isvaruntime
docker rm -fv isvaconfig
docker rm -fv openldap
docker rm -fv postgresql
docker rm -fv isvaop
docker volume rm isvaconfig
docker volume rm libldap
docker volume rm libsecauthority
docker volume rm ldapslapd
docker volume rm pgdata
docker network rm isva
echo "Done."
