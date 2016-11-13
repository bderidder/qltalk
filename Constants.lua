local addonName, QLTalk = ...
local L = QLTalk.L

QLTalk.VERSION = "0.9"

QLTalk.DEBUG = false

QLTalk.QLTALK_ADDON_MSG_PREFIX = "QLTALK_ADDON_MSG"
QLTalk.QLTALK_BN_MSG_PREFIX    = "QLTALK_BN_MSG"

QLTalk.MSG_SEPARATOR = "►"

QLTalk.RANDOM_MAX = 2147483646 -- max 32-bit integer value minus 1

-- the maximum number (expressed in seconds) that messages should stay in the cache before becoming obsolete
QLTalk.MESSAGE_CACHE_TTL = 10 * 60
