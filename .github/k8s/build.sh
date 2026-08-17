if [ "${GITHUB_EVENT_NAME}" = "release" ]; then
    HEAVYEDGE_TEST_MODE=0 make -j "$MAKE_JOBS" models-${MAJOR_VERSION} examples-${MAJOR_VERSION}
else
    HEAVYEDGE_TEST_MODE=1 make -j "$MAKE_JOBS" models tests examples
fi