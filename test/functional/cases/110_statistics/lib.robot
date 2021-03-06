*** Settings ***
Library         ${TESTDIR}/lib/rspamd.py
Resource        ${TESTDIR}/lib/rspamd.robot
Variables       ${TESTDIR}/lib/vars.py

*** Variables ***
${CONFIG}       ${TESTDIR}/configs/stats.conf
${MESSAGE}      ${TESTDIR}/messages/spam_message.eml
${REDIS_SCOPE}  Suite
${REDIS_SERVER}  ${EMPTY}
${RSPAMD_SCOPE}  Suite
${STATS_HASH}   ${EMPTY}
${STATS_KEY}    ${EMPTY}
${STATS_PATH_CACHE}  path = "\${TMPDIR}/bayes-cache.sqlite";
${STATS_PATH_HAM}  path = "\${TMPDIR}/bayes-ham.sqlite";
${STATS_PATH_SPAM}  path = "\${TMPDIR}/bayes-spam.sqlite";

*** Keywords ***
Broken Learn Test
  ${result} =  Run Rspamc  -h  ${LOCAL_ADDR}:${PORT_CONTROLLER}  learn_spam  ${MESSAGE}
  Check Rspamc  ${result}  Unknown statistics error

Empty Part Test
  Set Test Variable  ${MESSAGE}  ${TESTDIR}/messages/empty_part.eml
  ${result} =  Run Rspamc  -h  ${LOCAL_ADDR}:${PORT_CONTROLLER}  learn_spam  ${MESSAGE}
  Check Rspamc  ${result}
  ${result} =  Scan Message With Rspamc  ${MESSAGE}
  Check Rspamc  ${result}  BAYES_SPAM

Learn Test
  Set Suite Variable  ${RSPAMD_STATS_LEARNTEST}  0
  ${result} =  Run Rspamc  -h  ${LOCAL_ADDR}:${PORT_CONTROLLER}  learn_spam  ${MESSAGE}
  Check Rspamc  ${result}
  ${result} =  Scan Message With Rspamc  ${MESSAGE}
  Check Rspamc  ${result}  BAYES_SPAM
  Set Suite Variable  ${RSPAMD_STATS_LEARNTEST}  1

Relearn Test
  Run Keyword If  ${RSPAMD_STATS_LEARNTEST} == 0  Fail  "Learn test was not run"
  ${result} =  Run Rspamc  -h  ${LOCAL_ADDR}:${PORT_CONTROLLER}  learn_ham  ${MESSAGE}
  Check Rspamc  ${result}
  ${result} =  Scan Message With Rspamc  ${MESSAGE}
  Check Rspamc  ${result}  BAYES_HAM

Redis Statistics Setup
  ${tmpdir} =  Make Temporary Directory
  Set Suite Variable  ${TMPDIR}  ${tmpdir}
  Run Redis
  Generic Setup  TMPDIR=${tmpdir}

Redis Statistics Teardown
  Normal Teardown
  Shutdown Process With Children  ${REDIS_PID}

Statistics Setup
  Generic Setup  STATS_PATH_CACHE  STATS_PATH_HAM  STATS_PATH_SPAM

Statistics Teardown
  Normal Teardown
