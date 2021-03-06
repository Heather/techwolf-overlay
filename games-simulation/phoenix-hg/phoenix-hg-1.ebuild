# Copyright 2010 Techwolf Lupindo
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. Lastest version at http://gentoo.techwolf.net/

EAPI="2"
MY_LLCODEBASE="130"
inherit secondlife mercurial

MY_VIVOX="http://s3.amazonaws.com/viewer-source-downloads/install_pkgs/vivox-2.1.3010.6270-linux-20090309.tar.bz2"

DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://www.phoenixviewer.com/"
SRC_URI="vivox? ( ${MY_VIVOX} )"

EHG_REPO_URI="http://hg.phoenixviewer.com/phoenix-sg/"

SLOT="0"
KEYWORDS="~amd64 ~x86"
# KEYWORDS=""


RDEPEND="${RDEPEND}
	app-text/hunspell"

DEPEND="${DEPEND}
	app-arch/p7zip
	dev-libs/libgpg-error
	>=dev-libs/libgcrypt-1.2.0"

src_unpack() {
	# When using svc, S is the directory the checkout is copied into.
	# Set it so it matches src tarballs.
	S="${WORKDIR}/linden"
	mercurial_src_unpack
	mv "${WORKDIR}/phoenix-sg" "${WORKDIR}/linden"

	cd "${WORKDIR}/linden"
	# remove not needed source code
	rm -fr "${WORKDIR}"/linden/indra/libgcrypt
	rm -fr "${WORKDIR}"/linden/indra/libgpg-error

	# Convert the src to UNIX format from DOS/Windows
#	check_and_convert_DOS "${WORKDIR}/linden"

	use vivox && unpack ${MY_VIVOX##*/}

}

src_prepare() {
	secondlife_src_prepare

	# don't download Binaries
	sed -i -e "s/\.\/fetch_bins.sh/# \.\/fetch_bins.sh/" "${WORKDIR}/linden/indra/newview/linux_tools/wrapper.sh" || die "wrapper.sh sed failed"

	# add version info
	sed -e "s/@VERSION_VIEWER_MAJOR@/1/" \
	    -e "s/@VERSION_VIEWER_MINOR@/5/" \
	    -e "s/@VERSION_VIEWER_PATCH@/0/" \
	    -e "s/@VERSION_BUILD@/1/" \
	    -e "s/Phoenix Viewer Internal/Phoenix Viewer Gentoo/" \
		"${WORKDIR}/linden/indra/llcommon/llversionviewer.h.in" > "${WORKDIR}/linden/indra/llcommon/llversionviewer.h"

	# allow users to try out patches
	# put patches in /etc/portage/patches/{${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}/feature.patch
	epatch_user
}

# Linden Labs use ./develop.py to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	S="${WORKDIR}/linden/indra"
	secondlife_cmake_prep
	cmake-utils_src_configure
}
src_compile() {
	cmake-utils_src_compile
}

src_install() {
	secondlife_viewer_manifest "--branding_id=snowglobe"
	games_make_wrapper "${PN}" ./snowglobe "${GAMES_DATADIR}/${PN}"
	newicon res/phoenix_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Phoenix viewer" "${PN}"_icon
	prepgamesdirs
}
