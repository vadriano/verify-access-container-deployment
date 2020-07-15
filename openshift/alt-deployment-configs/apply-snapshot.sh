if [ $# -ne 1 ]; then
echo "Usage: $0 <snapshot>"
exit 1
fi

if [ ! -f $1 ]; then
echo "File not found: $1"
exit 1
fi

cp $1 build/temp.snapshot
oc start-build verifyaccess --from-dir build --follow
rm build/temp.snapshot
