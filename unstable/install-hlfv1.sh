ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.13.1
docker tag hyperledger/composer-playground:0.13.1 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �H�Y �=�r�r�=��fRNR�TN�Oر���&93��|��ëh��x�d���3 9�p@υ��|©��7�y�w�� 3��ɒ��5� ��Fw�F70����&�*n���m��vM-�k���D�2��I��Z²}$�Ũ�e!,=�hX?�=�_X\ہ �vt{>ܲ���A��cs<��q�����"{�� �e��&��7Ӂ���&l���S�Po�:�k���2�VGVh�|L�h[���  �m	[�6���!��[�l!� %��t�C��e���� ���h�Uhi6��N����5�@2�A�CB�ė�\ҷ	�"d)ZK7��iaà+#�BmX8��өE�H#��4��݄�l@�D�;���'�ٸy"&R2h���Z<��?l����.꾆l��ێ7!��H�@�51(,���&>�����z��(;�b�n����C�&���Yԡa/���v�4�a�4d�[:��Gt�˵�z�j�ۡ��9�.`�m ڃ��O;-��B���'V��`�UZ��v.E�Xu1_>\�.V[����8m�1�;�y���sF��C7G7�6�����G��Qil�)vafO��'�a�)��'����1��k���#�}�DN[MfW4T���[t� ˄���Lڮ>,�����+�
�P'@�?��нӠN^,����2��$�
�,F"�@��9�Q�p�o��;��Q�kz�5h7�J��d����D�?�%I�I������_Ey�]����*���]KE������]1�竄R��P>8*%�o��}l����A���O���� ������2C��������/Jk�_EY���]f��MXG�s��B����s��DI�L�tm�WT�s��.l9v"�A!�j��f��F(�:8Бu��#P�٫u����P����ڮEwf>ݶ�w�CYs,�*�纃���4`x�S��;~`�-y�p�t�yF�`l�Aڞ�7�<t���Ϝ�~�?CW�i3�
њ
H�Y=L";Rm������Xm�8<��ml�t@m��{���$�aUg�WC�ѷG�PuuC@Km���]���ˁ�'�!ZA�{�[2��t���b�S8�Xm�~�{�Ġ<<������ħ�ڐAv���k���ʂ��b)�v�.��O"O'�Iy�������@�<PsMv��t@S7 MX��;�T"`������K!�6��~��]qܡ�����D�m����5�z��"� ��<޿�(M� ���G�Qܐ��N��{�G"��}
�O���鄸4I�S��R/�N�߄��!�(�>��p �����d6�6�"�b8b���>��㶜q��"�u�����ǴӞΏ��!3�M�s�2��:���}��}�"��)	¦�c26�>�4|r�	e�>�X�6轏.L�]�a�(�&{N�����;��������:�����̳?��>�;ϙp��l����@�s��79Q��I��G��'�qzE��ިR�O��({��&S�W T-��^� �(��yu�c������UN�&Z[�/�̰�T���쇖۟�D#1am�WQ��?_v������'K�_��ش�������OJ��a<��;[`g4��3�]=�Y��9��f-X��4ײ(�j�[=.�+�|�r�Uvs��d)wX����M�o&�?��]��<{z5�FYb�r��x�%Q�%?�K��A��E�6�N� �m��6r^'�v[��6D�/h��l��GqȰ�|�#�
<{:��0Kw*��-W�R�C%�OU�s=6�w1�ۈL�fo^��D�1������y���B ���S�G��}��$��g��B��{0ܒ0�r.�۠@\qL�UE~�^z��R ҶtL�ttz@' �a%BFįχ�%�?.��bA@�I)�#6c�W���A����wkpk�Obk�o5e��}�e��Z�}n ��X���X8���U����ɧz}O�v�&�� �@�B5��8A<dз��U��e��O�Kw��L������a����|���NRp���o��r���KP��!���p8���+)S��t�M��l ���Kжt��_��Z��� Gw�ԡ�9�];��\qJ)�����~����S��'������w���>�{��Z��!߉^ddL?��W��[� P����c�΄�S)�c�4�B�I9�{b�@���?��3ު#�ۄ���AO�n̄~#Ģ�T�!0�Z� ���z�LW�3�;%N�`�t��TAs�r��M����/��1y��'���z��r����G�j�p�?t�ֽ����Q)�큷��A8m=�K<����@@
Aq�
o�"�s����[����ЪM��M��.A��?"G��_���������V��XƖ^o8�:d��B?�'����Q���J7����Z���9^�����U���?w����������تH3�������e �ZM�.��a������sQF�&8�B F]~��P��!T����?��A�x�Q=a����4��Rf�(��.ـQ���m`���� ��!~���md�%�L�4��@bF����@33gLP�N�1+1�D��\�]�J$��j� ��/� �<ʼ\)cyf�� �\�#b�G�̺�4�1Ѐ61���%R��̻��^͘*���#~������}�۟��1I^�����z�G���<��e4�/��+Db��?�����\I���k��������7�������Ô���'�
�,K�*����jMV���h��d)�,"9*ǫ�B9���jl+"U�"���������4�e�_��S�mC'�qD6��o����m�ѷO9.�M[��6�y㟸����__m��I$���7_���<�{����������w���?�.{��ߜXd�j��xL��vX1SB4�`Ư������{�r{�g�h�~���5���n�&4������������)W�k<�(�j���4YH�Mҗ<������<yz=��d-�}��z��������Q�!�
(��5��j[qTS����0"2�Ҡ��eA��Vƫb�8��H��Їخx�e�F� �N��D:�+�d�T�erI��f���|.�̞'����+�\B��JJ�=0�/zZ(���71��F�������Y��\Hخz��'�fV�҉F>y|��H_*�D�pLPU��B��5Z��k��/2�ʑ�L����3=�}g���{*����E���� p%����.��ٛF��&a��#�UI��M)Ѓ�W�R����ö́��6�B��v�9)_�	��tB��Y�0�{g��'����MOS��b6�}}|t�������%�������YGmEڧ��I>Q�z~�/�3����K��NO"��M�z����P�ݓ�IɁ'����/G��8j���o:�J⌌d"�M�>f�y9����d���M�*BNIdݭ��DQ�6/ʕ�1���
o�ӽ��M�q8)U^'v����q�(�Nឲ��ZY�#��Y��Mmʱ���K�39��ֻ{�Jb?��d.�Z��N��E:ǻ����c�[�'��VZ9W�|Ҧ��r�b3��Sr��u�X"���3��~�����n���KHf�y]z�%R��<����"ԕ|�(�+&e{�}g&�����)���e<r5̳�T.����Q�8�Ij�z�^��Eq���N�a:���cn����8�{���㱎V8*);�L&��Bj���~?
�~��f}_7��ƌ����O�D/7��D1*D���g��cgܲ������kw�����}_�����x��OX#�����1?鰔;&��OY�c.�����,�щ�Ѕԇ*낐���'�����j�1wv�e�*dO�cdRH�,�M�m�+�(%����G�R;Լ��d����J�E�s�q�W,Ez���"GǻRV�''��n�@BT�P�����v+j�D��������]����_N�e��������*�g��n�sw}]�2�4�����������~.9n�3�n�{��$���($��T���a�k�3�#Xɼ�_��ݐ-���6<l�s� s��7�HuKgo��L)��X��mqoo�y�N�T�⾭w/��n۬Wr0��wv��4g�{�~;����v0,���`��W��z�wD^�\My��ݳX\d.�'߬v(�J��%��BrOh��a�M`�K{��rk:���(�-�#���+�E Xu��B5��Y��Ѩ.h��@�-h�:�~�G-k���}�4��i��EN�� w ؏��( ��-���`,����7m��/���f�����(�*2p�� ѥ�@c	�������v��x������7�b�� "<���.>��2�#ɝ|h�}0�G&��q�N�e:f�E&���AtA�t���՘��D�
zص||��v-&WA ��/�A�^`�B��R"U����A�������aݦ �	�e�%H+	_��#��N0��QڶNY"�Nb*�׷'S�����d{�	*����y	lh�~�W:��1<I2f��d��[2���x��k��ݣ	m�#���c��K��d�m�ҿDo��b/���'oO����_]�����'��>�����J�5�dl;�pIkn1fh����%�9��
�4_�m*hd�&�c�����0&uz˛�xR3'������X)F�#��p0���T���@��*�,b�J`f�T�֜�ˇ[\�p�q�pwt/zr�j������]���� Dئa�,r��������k��q��՛���7��Z	t�Ib�t�@�N�K�_o���K/S�YB�5�|�]����X�kSC�y�~�������Kg�P�K�c���᧪�|0Ǜ�	,`��õ�];�C:04�t�u\: dQQ�&ZD֊A?� #P�N���/�^&kJ���S�^�غ\Eq�dE'H+���J�v�!>Ƽ�C�?�a?��T&�8�M۶����n:�� 2��Y�Y2�~�|��i��	���L��l�[����cP��Pj[TU���5���4�<c�@��NMВM����֑I,�d?b������(�?{��8���{���nz���B5Ӎ�R�Gb'�LIm�N��8O���ʉ�ĉ�'Y�b��f�%���nF�CblaX ��ĂB�5�?�<�*�P��ֽ�y��u����!ls�O�����<~%��~�g�?��.�ŷ'E���?W������o���~G>Ǒ���������譣C�����5t1�ʟ~�Bѐ�H��*�X�
G�r�)IaM<#íA*dT�	�lK�!��_H�x���~��|���~��W~������䏞��8�{�],�;X��G�^�h��_����� ���z/��� ����?"_J���=|�0�O��v�m��{��n��b�S.Z�����n4Z>6�t,��z�l2,}�t:��~/�/X��,�
�-��W!>tUC`Zv�P؍��Z3�XsA��ٝ�V&6�.iB���B�@
��d=[��
�3DH	���N���HkQ(
&g���1[��ǍAl�h]�X74|��L\�����ns����L(�̈́	3�rs�k�T��*n6��i��B�4���E�y�W/��3^����3l��׏��iz���y͠:� S<���S|id�|�k��t"�.T���~�.�쬄��3%Y,SVF�+e�B3Y��"��)�����$����5?]O"L�A��	3�v�I�ْC�Y!��B')�yD�:)��"}.��F�4��05+��"S����yx���*�4߉/&=T+��.q�@汨F.��L��w��.����43���dMk�IJ�UKe�H'�Qz6nRbnn�'��X9�����������^�Mw�^"w�^"wE^"w^"w�]"w�]"wE]"w]"w�\"w�\"wE\"� ��0�.�f)E���O�J�Õ�Rb��9��7��x1���8��60�.��q/jgE�s�*'�K螻�<R�[��۩����@���������A\�S붗yj:Ċ�Hz�3D渁gC�iT�r���f	~����ܔ	�jiZ=G0��S�DY
7��&��	N���Hj��j�����&�'����8c+s�ٲ�#t-��Itoi⭈�Sf�[87/T?:5�r82�1J�a�C�9�)�fbX�vb��(N��<]�D��eS}BᒹӊJ��ܤ�Gd��J�~�̢Ԁ��˼[�w��ہ_8z=�A�(���G�=z��r�?� ���u���n�}���o���&���G��Z>	�s������G�N>��^�:5]���/z�����x#�ׁ�����[�(������+�o<��c>��������<��+EYfi�2YZ�|ވ�r��2y���r�b��ۭ-�/�/Z�'X����8���-3a�3I��Pr!���Ky������\�-�
&�qD�ilJ����]	���o� �D����tZ�������x�BH5J����Ȕ�S�cv�W������T��ln���z�X`��z�mQt|�TZ�8i�F�֣��6H�;*?NWFx�Dj"���L�x����+�4k9M�S���4K��� #�@��P!iAf;��3R�[T�F;*]n'���HĐ��sK�l=Qu�4_�/�SdMQv�)�e8Z�՚���k�&.v˃A�D�	�k9˂�`d-�~�l!���9m�����]f�tÚrܘ3U���-^�J�d�G����ǿu%�ā����B=��|yP�����δ[\n�����e��]���4�K���� �u�#�q��"��"��Y���j#�o?c�gf��e\vGn��.�#����u�{����7�ڴ���
G�[�e:��Ɇ�Vyc֑�|&Oԓ�8�Vla8,)�zܯ���X�.}6�0Ōb4��í��y���è���F��J��lV��*\�ڴe�6��M��6���x��Gt�:��Sȇ�N"5�u���8R힟Z{:��A�|�W:�dZ�R�%��b��҂4=mբy%٨(�T�/��1�.Efi�	�ys �7.5/E�a:��&S�v?�Ry.B�[Åip�X�1#�x�E��³��y%OdE�H+E"dg��xXS#S�1�+��-��l��U$#3I;�d�p�G����4�2An{�*de_�L$k;�*�"0�]�����W+�Rz*�+����X��R�C��Vp�	���c.���*�5
%�Cp�cq�K+ճ(�<Ki���M��et:S��;�
q5��)g��y�)�����E}h:��*��=����	җ�BJܐ��Ba�nF-E�N���|��r�J7D�V����l��5�T�Q���a2j��4�cSi�4���%��P6�-�F�U��r���.c&�.���_|˲���w��M7��ٍ�/Z���.�����<tlѢ���*8r3>�e�g�i�2ԧ��+����7��6�<F~���V��.��{����ϟ?�?|�<�����#ڎ���D� V�>E�΀oISeۇ�]�@\ӛĕ^)�y�y��t���:#��� ���#2�q>A~����)P��8�8uG�k��{�y䁳8�,O]W� x�|�`���ҡG��"�2+G�k��t�t�� Od̯����������H/���G/8���A����ד ���
�;��ts�����T�
�/�Vf��z�;�0V%���4���Ŏܸ��;
���4���3"�_���926ifw��]���H���I�S�k�*��9?�t�l�㧫���3�z�폭�U^Ѣת����U�ɎN��h���s�cj|oo==VG_Q�lH��z?<�HPP� !=����%-�8F�G10E�6��'
,Բ� z& 1�"v*�2H}c�]\ �3�w�ؤaв�S�� �fq.���Ի��&������ �˩O��/O��jNW@���+��V��&>$�MO��`������z�_ g�ADVТ3��1���X뭭u�v �w�W���h~�ʬ��A�|��,] R�̢�'���g�*�L�*�?Yu�b[�h���%���q��{��юW�]�Ip��:�z�"�gm�}��e�tb���2z��$��6�O�aKK�I�8�j8���jQ;�+��@��z!�g䊉+�������ԃ��?�0Ӱ�M���	�����* �.6��u��~�_�/�LF�}=w�_�1t[=:�� ��`S!z,-{�Q�k28� ނ��>�)OB�P��Zm6����6o(�� )�O◧q���粫k@W�g/"��B�m��p~в���dM`e�%�s%k�hٺ2�^���-%O�{��Q�� 8\�a�n]\*��/ ���P�$U�/cX%m �cp.�bz��v_�a�Nv �ݶ��^q�Eo���#�c��� �	����ӔT�=rQ�@�J�&(�񟅜	}�vp��,�]� _�.� Q�6����*�u�ii�~��@����`WV�ce2����C�&͝�\2�o�nZ�<�t;h�Y�$�s�>�n�	r�#��[�E ���D�4kX򪋫�=]�8�	�e��X4(0����.�lto�x����c��� �ކ�8m1���j�i"�-B���W�Z%kݶ�����jBH��:3r
����23��z�:��:�k�'ش_@���1���^�U�͉�	�C��	�z?붉�ֆ�Ɖ�S�9�a1b%)��������_��$�-4egCi�@'(�w���w\qpl��b��Iߑ���j�����
$��܏:�����������������m�����+���b3�'�`��}$��!>!>A@j˶Jv�ܰe%�vr��h �oó�g���"?��g 2�3T1Z�����Q��+\����*vt��R��Y��\��ծu��'���ӱrEC�\�f�H!K�I5	Ij���HdH	�m�j�ZJ�#m\��f��?F��v���p8�H%��}[�����DX�ì�gN,�*�����l�Ƕx�O�'O�Pa̐k�bǂxf��W7��IM����&�bY�qB	�0)&IE�cJ�RQ%$5eBB
Y3�)ሂK��X|Ҵ�����c3�D���̲��o���7�;�$�亣q��	Ovfߓ�E�V�]����wd��cw���msE�+ZT��\�Μer�W�2�d�9�\��/�\�f�"W*=àu�]��[�K'�r�3x�E�����_pa�A��P���3���U�A���.��{��U@@�[;�3�Π���vF�\�'-���i���Z�3��b��-��o�A�6io��;]k�nxl熉Bw�!���V7g�j}��nz��0�b�ߊ�y!��sEy��&��W� t�>���l<Ǯr�<�rL9���"�qY6����P���(
�Y�3i�N�CǶz������Yy��?��m�&<Z�����ZES���e|�,ˉ�\�T�F��e�3����F�X�>���d=�k��bj�g@�=fY-�&��%�9�'K�4C��gq�e.�ϕ�)�q����N�1��E�/�A=�-�O�8��L>kK��\����"�xc0��EL���:Mݝﯡ���,���vs��:߲]��d�X��`��2V��~��0���{�F.u���N���ͮ��;V�ߊw�#�9+3V���@!t����3��m����zq`�&�f�_�$9��G���o��6n��!�|'뿏���KF�f�CD?��>�+���ķ�c���H/��MoI�	zH{H�X�[�*t��{I���'plS����A��#�K�ß��i�ʦ}��K������_ �����hhh^���f��W��#w��:�{I���9&Y����E�v$*����l�Ȗ"K�X$��*�EۡV�����pTib���	�u��,��j�Wa���m���k/�g�m�ɼq�O�}\S��:iet�:G�+b�M	�;�4��u%?��8ɍ��$P=��E��"m.U���rH!2��@��E��-�=�ޖ�����y�?����ޤS)N�Z*^	a1eV��a�;F5��؟�����O���?���_z���Ɔ��8iw����������H���'�������Gڗ�� x���ʧ��?�����[�d$r���H�,�R����+��� ��]��������
�x ��D�O����.�Ij[�S����j��G�Jti_��2�g����?:|��?���KMl��+λc��/g������^� D�(*ʯ��*&���J*)؝��T1��(:�k���pT'�	Gu��G8H�?���'�T�_�C�_�������<� �W���Ck 
�?C<����[	ު��[�m>�*ݠ��y�qXw�N��K���?�Z�?CCJ����m������c��1޽�y[��޷�Y�דYL=�o�����,�`��¯VyC+��E��z�E���U�9�n��:Q̅�*�:_G���Z�a��
�E�j�'����=t��72������'�={�m���q�wȃztĝ��`^�))͞,m�^z��j��v���}ʗ���v�i꫱q���f�F�s�}#�h9��ʴ�{�X�ړu�2���a(���x������e��b���G����L$���k��eA,�z �����������R������'������O���O���O�	��
 ���$���� ����������_����H���o����B��������Z�_��L:�bz�,���:�n�����V�����u�����ƣ�!�}Y����:n�5�i@��`��CymĻ�`���H�i�ޣ���eB���FA�4I�B.���:cvN���>���no��ij�R�c��#����^}�	�Q,�ג~)�V���_��ؽ���m|�����u:!;%���;�ewŒ�HI��t�2��^2)�l�5���b"��3�ǋФ%i�_���	��V`�|�	��c�td�6���/��߀��#��?�_@@���K~H���5 ���[�����W�/��W��6.�3�,�Yb��L@��B���|R,�\HRA�S!2�@x�����Y�?����g���e�ӗ�DJ�V�d�<��Ӿ��Fԩ�,[�dm�S����3{{���S�.�#�Tݽ�ّ��66]���jrX�p�.6[J�=��y�&������� k�L�>�ó��:����@���������a]�Z���������Om@��_��2���7
��_}����ѴT稫��vs����3�uW��n���;����S{�WGr<h&�o^r�+df��Ses��;	e����*ƇqN��TqGv�.����p��`�<�-U�u���߷��?	�oM@�����_��7 ��/������_���_�������X�����(�_xK�y�U�����ALڲ�G�̈́�BM���!���%��g����v�cW����3 ��� ��z�� W��G�p)>U����7� ��<���.6�CJ�e�%W���ϱA�Ք�n��Zۥm+ö\�d#6���ODu�����^>�wUo�~)���f{a�Ş�Dߍ�OO����|�� �ے
C��{)V[�U|b��蓾�i�� 2ۧ��<Q��H*7X��9�Sv?7iW�9~�@���!5��VZ{�x~�I�&���x�@(�%k�H���1k5�ٱ[�Rc:�;R�L���b);��Ft�/�=1���Ќ��\d�ׇMjt��ag��">K&�_VNW��E�P��D�Ѡ������C&<�E�����8��p�T��ğ�`��T����,��������������������_o���5��G~�2~8���̟dD��/��ϲ�q8�����i>E�3^�h."|֏`��ÀB��l���O%���^?8�J-s��f�9$�$9��Y1za�Ftɚ�ZL�i��*�$���ŶKzi�[����]�?5�!��PR?K6�~��Iua�7�ˈ�E�^K�:g�ǎẤ��e��Zξ�S���~+P���������������%��P�����R��U 	�g������?�$��"��������U����P9���/�����*����w���
���~�����o��ߎ��e֔ڗt�%��Z[��aY���"���o�4؏�~��~d������q��(��xx�ǌ��S-y؛���#��%�h�ζc��މ3'�T/��,����J�mo5q�;��������$��y��
oڜ�����h�Ҏ}�8R��6v��*�Y�kۉ�o�6{�?r�&	�~�[�f�m�(��~��-�H�.ӡ}��8����ʚ%ӹn���ƻ��F4�3����������-F�I�5c-��M7f�2K[����Vw�����|<�ȴ��f�;�ˮ(迫ڃ�kB5��wGP�����'	
�_kB���������7KA�_%��o����o����?迏��u ������(�?���C����%� � ���I�/EC�_ ��!�����?���A�U��������y��������������$�?����������m�n �����p�w]���!�f �����ē���� ��p���_;�3O����J��C8Dը���7�����J ��� ������x�a��" ��`3�F@��{�?$��y�� ���?��� ��g�4�?T�����������I�A8D������H�?��kZ��U���I��� � �� ����������J���˓��������C��_��8�� ��0�_9P��a��>��?���������! ���'�� �W����}������(�?��{��(�?A\�`�G���)���B4����+I����C��C��9_������G��]���K@�_�T����Z�GW����ݹV��?U�R/��7`Y1�kE�'�i��U�b^_�61���x�>�[J�C�ڒ��P4eQ�Orn��03�U��e�Q�荼NAc�h�^�!saZ�qG����b�u����Ɉ�C����KO�8x��$c�����I���#����Yj������(�����H�?��������q-�~1~C���P�Շ�Y�B�`΍C�)Z���a�Foɝ�`V���"��E�ԭ���s���>�k�l���C��m����5�,p�<f�Gg���vMwz����].�ٹ-�;C�)2kFN��Q�m���ʘP�}+и�?���oE@�����_��7 ��/������_���_�������X����3�����-����k�R7Q�X޳[{b��/�V���V���߫��I;E�$�Md��ľ%��z�~�9a���V���4b�C��L	v�D��ph�'�݋�,>��c}�.Ų<�9���%��lF�����fn��{�v���+}��{�t�m��r[RaH���^�Ֆt�߉K���\蓾�i�� 2ۧ��<Q��H*7���9�Sv?7iW��B�P-Y�p���	����D0�T�ϴ��<��͹w����(4ڽ�����'3��
=?ՈY�Z3A$�8�L�Ft�Q��|�1���ﯻ+�����g���[�׿����8GB��|�����������p�� 
�A?�����J�џ��D7�BU\���'8��*���8�������@5����	��*�����k���I��*��g:�,�._�?󴱲�$�!H��§��\(?;�����=�C&�n��E��qS�?��+]c�=��h/���s?����
5���-_[��!�w�rx�.o��-��sl��)?9����u5$�����-e��P��Fή큊}=ި�^m�L�sq>&��g�ZL�e��-
��l2ҡG���u�ѢM�K�xJ0�\�S�/&��m��/Vދ��O������R<Uo_��8��~��7;ׇ�NӐ_�3%�I�8�7uvTC�v۲�#b�o+�i,#�*{l��F���e�͎�H��H䢗ؼD�t����`f���9�d"��i��k����n�Z,%nӗ
�<ŏ�&(�=��ԦB�/��c��+����~w �����?��V�j�0x��ps��I_�S!�_��P��4���|r4%�}�ؐ	�(?�Cb������������J�3��6���p�I�pL�f��(���1�v�h��������\��Z��#Wnj�����������0�_@A�������|���CU\�7�?�q���W	���z�����ځ?��<���b��p������;��a��4P�̋�w3ذ�y���~؏x7���obH�����}���}��gQ���XRI�:ܑ��nC�Qkia;��'}&l����`�i$|�%�"dEyDa����٣Ŝ���ɦՍ-�n��^��n�aO|??P�M"��8�y�!�w���N���E���t1��u��'&��L��,��fD�N4��դ-Qb�	�V�Y�E��ןj�u��2'�i-�u��N��X[v�f�k���h�b���~w����g�?��[	*��3>�a��<�Ss�$o���~�pQ4�'|����߄W]0�	��I��>B������������������_��n�6-��v�i��gz��q�自h�Y9�$�����-7Ղ�W���������-���G���U��U�=�?�_�����v�G$��_7�C�W}���_c ���������?GB�_	���ȷ������ִ��4wc�^O�{�<>.����O�pI��?��>��U�������\�C��"��(�J��b.Ջ��.�:�>��>�|~�-�޽s���uu�\a/GW.����w�Ojb�������:uny�y�CO��*@E�}��u+���N��~��N:љtf�l&�OU�v�[���^k���kV���>^���Jxa/�<���i9�Bg\�D{[[w:�T��hV�n�l=����}s|��*&��h�6�2�rڶ�t��H�1k	\�m����J	/Sh
�y���y�G�)q�<��n�x�=���gw;�b�ꇽ��v~��6lIi6F�í2�%Ym^���'�u����vcR��ld���j0��U���UL,ZJ�Ѷ�f�~���#ؕS�벵��R��p�qT��J%)�H]�+����|ß&�um�o��Ʉ,�C�?�����_��BG�����#��e�'_���L��O����O������ު���!�\��m�y���GG����rF.����o����&@�7���ߠ����-����_���-������gH���!��_�������_��C��@�A������_��T�����v ������E����(��B�����3W��@�� '�u!���_����� �����]ra��W�!�#P�����o��˅�/�?@�GF�A�!#���/�?$��2�?@��� �`�쿬�?����o��˅���?2r��P���/�?$���� ������h�������L@i�����������\�?s���eB>���Q�����������K.�?���D���V�1������߶���/R�?�������)�$�?g5���<7׭2m2��ͭb�5M�dR�����d˘d��ɱ÷�uz��E������lx��wz�(q��Fu����u��
M�)�ǭ�o2��wY��^�պ(����t�6ǝ6&w�Ɋ~HS,��8�m��/k��Ȏ�d�)-zB:]=h�V�E�Gu:,�q;,����m����d�U��\OS���՛�nǮU#�rEy�'����$YG���Wd�W�����E�n𜑇���U��a�7���y���AJ�?�}��n��%��:~��'jv��w�^���b�Q�ˆ��m��m��E��Ξ����Fu�j�[��j���#��͆�6,E�D8��~],���ߪb۰�sUk��ɫ�v��]mN���&�P;z��%�����7�{#��/D.� ����_���_0���������.��������_����n�QP�C��zVa��U���?��W��p���)VĚ8�)__�_ف����6��h�@*���z�.K�l�?���E��5}4o����D�0.L�x\��!iͱS��ˉI�U'�N��z�����~Q�j�J)l�[m,���m
��:;���_e�*��і����D�Z�F�1M!��bwXO����h�IJ�}v~s��V�~������^�|Jb���*P���r��KQ]٨5�V���v9X��ͦ2⇃8?LKQUZ�X�8���N�Y2D{�����qqېI�]?hB����|/Ƀ�G�P�	o��?� �9%���[�����Y������Y���?�xY������������Y������&��n�����SW�`�'����E�Q��-���\��+���	y���=Y����L�?��x{��#�����K.�?���/������ ���m���X���X�	������_
�?2���4�C����D�}{:bG[U�7��q������0�Z�)�#fs?��
����s?���L�G����"�w��Ϲ�������uy�ݢ��]�D�����8�P�;fm���\����j�7��O�gCvfNcap���M#��8:�!,Y��dSSmG��Q����Ѽ��_�Jޯ�WOG���\�F��4��
�}8V�����tu���_����Ug"��`1�lF90'<���%ik��Nt��jX#9jSo�}2�V,�X���`�fa�w��ReCi��DpT���vra���?2��/G�����m��B�a�y��Ǘ0
�)�������`�?������_P������"���G�7	���m��B�Y�9��+{� �[������-��RI��_�T�c�Q_D��q��Hmك�d�S����>�ǲ�<<�����،��i
���=��)������0��ыFI�h���z~��T�i��,u��7CS��W�*G}���hA�F�P/rq{+��eY!F�o� `i�����$�����B�{�X�/t)E�W��|aʜ�b�-?
�¢��nkO�����lX޴��P�G&��^S:K�X�!m�WЭ	�m�������?L.�?���/P�+���G��	���m��A��ԕ��E��,ȏ�3e�7�"oY�fh�f΋�N[,�s�N��E�d�l��a�OZk�:ϙ�O�9�c�V���L�������?r��?�������O�H&O��Q�Q�Nf��j�j�4*���<�ބ&{�`��Vb�埈`g��kL^�J���������ʝJ]X��5rr�4׉Y<�ZV p�|��n4��?_K���������q�������\�?�� ��?-������&Ƀ����������z�X�􎬊Ĝ�*Ċ��K���[Q�Ew��/�N��>�\_:���`K��_a;�YRL=4�,�G�~u�N�����[�iW||Ռڲn0.O������&^����24��%��E��3��g����``��"���_���_���?`���y��X��"�e��S�ϖ>�����ct�\���t/B�����S�����X �������wں�E[M�$������q��tc����r�J̧2�"��rV�#��'�`�)��Byh�X��a���שҬ�ڶ��RW�/�<,��DM���';O|�V�OE�;�q:&�BwX��u� v-a��$:9�6�RIv��������my�(�+�*"c���=QJ��S�M��MԵ�_�S��i�򳽈}U8P��Hԫ+��u��ˆď䓻p��J��ڞ[���b�n�0Fb��*4��Â�S�}�1�Յި���|8ezTqZ&�r�w��#O�9��}tx]���'����B�i&��?�ݹm�x������:��_v��Gm�(�����	bO�>J5�cG�?��+�y����<�Y���t�Ϧ��|L������]$�=c��������{=���G�����CI�������5�L�X���R��7?�%�����?}J����p�}���?�㾊��i>�����������.0�ox��D����n���Ǎpm�N������{,4#���'縉�i$����I_�zR��v��I�d���r��x�0qcfr��${{��(����7�x�#����w��~�c�=�I��%���w�����w܏�ɫ���[~I��OO;v������<Q�T ���;�r��}u��������<��XK����~��`m�m3�Ϗy��ӕ�渆�޳�M��"�`纎k��DނO��?q'w&�� �Bo�q�4����ÿ�Z�~����f�?�i,<��/���צ�������{��$�|��9��f@�{�M�t����?n�q��W��œ,���67aF���x�s�pM�ӓU=���SJZ��E�qwɍ'�{Տ�j�����H�VM�;���Hva*�����t�w�j�ez�w�ח������=q�}                           p����� � 