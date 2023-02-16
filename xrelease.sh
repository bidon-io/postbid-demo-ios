#!/bin/sh

# ----------------------------------
# ENVIROMENT VARIABLES
# ----------------------------------
export ERROR='\033[0;31m'   # Red color
export INFO='\033[0m'       # Standart color
export WARNING='\033[0;33m' # Orange color

SPEC="BidOnMediationSdk"
PODSPEC="./Specs/$SPEC.podspec"
VER=""
TAG=""
NOTE=""
CREATE_TAG=NO
REPO_PUSH=NO
TRUNK_PUSH=NO

# ----------------------------------
# CONSOLE IO
# ----------------------------------

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      echo "[options][arguments]"
      echo " "
      echo "options:"
      echo "-h,  --help                                       Show brief help"
      echo "-t,  --tag                                        Creaate tag version of build. ${WARNING}Default = NO${INFO}"
      echo "-rp, --repo_push                                  Update CocoaPods appodeal repo. ${WARNING}Default = NO${INFO}"
      echo "-tp, --trunk_push                                 Update CocoaPods public repo. ${WARNING}Default = NO${INFO}"
      exit 0
      ;;
    -t|--tag)
      CREATE_TAG=$2
      shift # past argument
      shift # past value
      ;;
    -rp|--repo_push)
      REPO_PUSH=$2
      shift # past argument
      shift # past value
      ;;
    -tp|--trunk_push)
      TRUNK_PUSH=$2
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "${ERROR} ❌ Unknown option $1${INFO}"
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

# ----------------------------------
# METHODS
# ----------------------------------

function parseVersion {
  while read line; do
    if [[ "$line" == *"spec.version"* && $line =~ [0-9]+\.[0-9]+\.[0-9] ]]; then
        VER=${BASH_REMATCH[0]}
    fi
  done < $PODSPEC

  TAG="v$VER"

  if [[ $VER == "" ]]; then
    echo "${ERROR} ❌ Can't parse version from $PODSPEC${INFO}"
    exit 0
  fi
}

function parseNotes {
  while read line; do
    if [[ "$line" == *"##"* ]]; then
      if [[ "$line" == *"$VER"* ]]; then
        NOTE+="$line"
      else
        break
      fi
    else
      if [[ $NOTE != "" ]]; then
        NOTE+="\n $line"
      fi
    fi
  done < "./release/CHANGELOG.md"

  if [[ $NOTE == "" ]]; then
    echo "${ERROR} ❌ Can't parse notes${INFO}"
    exit 0
  fi
}


function upload {
    echo "🌎 Upload"
    name="$SPEC.zip"
    aws s3 cp "$(PWD)/release/$name" "s3://appodeal-ios/${SPEC}/$VER/$name" --acl public-read
}

function createRelease {
  PATH_NOTE="./release/NOTE.md"
  NOTE+=" \n - [XCFramework](https://s3-us-west-1.amazonaws.com/appodeal-ios/${SPEC}/${VER}/${SPEC}.zip)"
  echo "$NOTE" > "$PATH_NOTE"
  echo "$(tail -n +2 "$PATH_NOTE")" > "$PATH_NOTE"

  gh release delete $TAG -y

  git tag -d $TAG
  git push origin --delete $TAG
  git tag -a $TAG -m "$TAG"
  git push origin $TAG

  gh release create $TAG -F "./release/NOTE.md"
}

function repoPush {
  cd "./Specs"
  pod repo push appodeal "$SPEC.podspec"
  cd -
}

function trunkPush {
  cd "./Specs"
  pod trunk push "$SPEC.podspec"
  cd -
}

# ----------------------------------
# EXECUTION
# ----------------------------------

parseVersion
parseNotes

echo "🔨 Release configuration:"
echo "Spec name:         ${WARNING}${SPEC}${INFO}"
echo "Spec version:      ${WARNING}${VER}${INFO}"
echo "Git tag:           ${WARNING}${TAG}${INFO}"
echo " "
echo "Repo push          ${WARNING}${REPO_PUSH}${INFO}"
echo "Trunk push         ${WARNING}${TRUNK_PUSH}${INFO}"
echo "Create git tag:    ${WARNING}${CREATE_TAG}${INFO}"

[ "$REPO_PUSH" = "YES" ] && upload && repoPush
[ "$TRUNK_PUSH" = "YES" ] && trunkPush
[ "$CREATE_TAG" = "YES" ] && createRelease
