#!/bin/sh
set -e

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

case "${TARGETED_DEVICE_FAMILY}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

realpath() {
  DIRECTORY="$(cd "${1%/*}" && pwd)"
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\""
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "$RESOURCE_PATH")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH"
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_applepay.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_applepay@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_applepay@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_applepay.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_applepay@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_applepay@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_back.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_back@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_back@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_front.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_front@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_front@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_add.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_add@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_add@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_left.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_left@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_left@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_right_small.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_right_small@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_right_small@3x.png"
  install_resource "Stripe/Stripe/Resources/Images"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_amex@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_applepay.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_applepay@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_applepay@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_cvc_amex@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_diners@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_discover@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_applepay.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_applepay@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_applepay@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_back.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_back@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_back@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_front.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_front@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_form_front@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_jcb@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_mastercard@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_placeholder_template@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_card_visa@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_add.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_add@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_add@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_left.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_left@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_left@3x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_right_small.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_right_small@2x.png"
  install_resource "Stripe/Stripe/Resources/Images/stp_icon_chevron_right_small@3x.png"
  install_resource "Stripe/Stripe/Resources/Images"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
