DISTRO_NAME="Kali"
DISTRO_VERSION="2019.3"
BS_TRUE=1
BS_FALSE=0
_SIMPLIFY_VERSION=$BS_TRUE


# Simplify distro name naming on functions
DISTRO_NAME_L=$(echo "$DISTRO_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9_ ]//g' | sed -re 's/([[:space:]])+/_/g')

# Simplify version naming on functions
if [ "$DISTRO_VERSION" = "" ] || [ ${_SIMPLIFY_VERSION} -eq $BS_FALSE ]; then
    DISTRO_MAJOR_VERSION=""
    DISTRO_MINOR_VERSION=""
    PREFIXED_DISTRO_MAJOR_VERSION=""
    PREFIXED_DISTRO_MINOR_VERSION=""
else
    DISTRO_MAJOR_VERSION=$(echo "$DISTRO_VERSION" | sed 's/^\([0-9]*\).*/\1/g')
    DISTRO_MINOR_VERSION=$(echo "$DISTRO_VERSION" | sed 's/^\([0-9]*\).\([0-9]*\).*/\2/g')
    PREFIXED_DISTRO_MAJOR_VERSION="_${DISTRO_MAJOR_VERSION}"
    if [ "${PREFIXED_DISTRO_MAJOR_VERSION}" = "_" ]; then
        PREFIXED_DISTRO_MAJOR_VERSION=""
    fi
    PREFIXED_DISTRO_MINOR_VERSION="_${DISTRO_MINOR_VERSION}"
    if [ "${PREFIXED_DISTRO_MINOR_VERSION}" = "_" ]; then
        PREFIXED_DISTRO_MINOR_VERSION=""
    fi
fi

echo $DISTRO_NAME
echo $DISTRO_VERSION
echo $DISTRO_NAME_L
echo $DISTRO_MAJOR_VERSION
echo $DISTRO_MINOR_VERSION
echo $PREFIXED_DISTRO_MAJOR_VERSION
echo $PREFIXED_DISTRO_MINOR_VERSION

DEBIAN_DERIVATIVES="(cumulus_.+|devuan|kali|linuxmint|raspbian|bunsenlabs|turnkey)"
kali_rolling_debian_base="10.0"
match=$(echo "$DISTRO_NAME_L" | grep -E ${DEBIAN_DERIVATIVES})

if [ "${match}" != "" ]; then
    case $match in
        cumulus_*)
            _major=$(echo "$DISTRO_VERSION" | sed 's/^\([0-9]*\).*/\1/g')
            _debian_derivative="cumulus"
            ;;
        devuan)
            _major=$(echo "$DISTRO_VERSION" | sed 's/^\([0-9]*\).*/\1/g')
            _debian_derivative="devuan"
            ;;
        kali)
            _major=$(echo "$DISTRO_VERSION" | sed 's/^\([0-9]*\).*/\1/g')
            _debian_derivative="kali"
            ;;
        linuxmint)
            _major=$(echo "$DISTRO_VERSION" | sed 's/^\([0-9]*\).*/\1/g')
            _debian_derivative="linuxmint"
            ;;
        raspbian)
            _major=$(echo "$DISTRO_VERSION" | sed 's/^\([0-9]*\).*/\1/g')
            _debian_derivative="raspbian"
            ;;
        bunsenlabs)
            _major=$(echo "$DISTRO_VERSION" | sed 's/^\([0-9]*\).*/\1/g')
            _debian_derivative="bunsenlabs"
            ;;
        turnkey)
            _major=$(echo "$DISTRO_VERSION" | sed 's/^\([0-9]*\).*/\1/g')
            _debian_derivative="turnkey"
            ;;
    esac

    _debian_version=$(eval echo "\$${_debian_derivative}_${_major}_debian_base" 2>/dev/null)

    if [ "$_debian_version" != "" ]; then
        echodebug "Detected Debian $_debian_version derivative"
        DISTRO_NAME_L="debian"
        DISTRO_VERSION="$_debian_version"
        DISTRO_MAJOR_VERSION="$(echo "$DISTRO_VERSION" | sed 's/^\([0-9]*\).*/\1/g')"
    fi
fi

echo $match
echo $_debian_derivative
echo $_major
echo "\$${_debian_derivative}_${_major}_debian_base"