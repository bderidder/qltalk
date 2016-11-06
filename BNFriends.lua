local addonName, QLTalk = ...
local L = QLTalk.L

-- Dumps all BattleNet RealID friends (debugging function)
function QLTalk:DumpBNFriends()
    numFriends = BNGetNumFriends();

    for i=1,numFriends do 
        bnetIDAccount, accountName, battleTag, isBattleTagPresence, 
        characterName, bnetIDGameAccount, client, isOnline, lastOnline, 
        isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, 
        canSoR, isReferAFriend, canSummonFriend = BNGetFriendInfo(i);

        QLTalk:Debug(accountName .. " - " .. tostring(isOnline) .. " - " .. tostring(bnetIDGameAccount));
    end
end

-- Function to return the 'bnetIDGameAccount' (BN presence id) for a user
-- 
-- characterName: the name of the characther
-- realmName: the name of the realm the character is on
--
-- returns the bnetIDGameAccount or nil if no such player exists
function QLTalk:GetBNIDGameAccount(characterNameToSearch, realmNameToSearch)
    numFriends = BNGetNumFriends();

    for i=1,numFriends do 
        local bnetIDAccount, accountName, battleTag, isBattleTagPresence, 
              characterName, bnetIDGameAccount, client, isOnline, lastOnline, 
              isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, 
              canSoR, isReferAFriend, canSummonFriend = BNGetFriendInfo(i);

        if (isOnline and (client == "WoW")) then
            local hasFocus, characterName, client, realmName, realmID, faction, 
                  race, class, guild, zoneName, level, gameText, broadcastText, 
                  broadcastTime, canSoR, toonID, bnetIDAccount, isGameAFK, 
                  isGameBusy = BNGetFriendGameAccountInfo(i, 1);
            if ((characterNameToSearch == characterName) and (realmNameToSearch == realmName)) then
                return bnetIDGameAccount;
            end
        end
    end

    return nil;
end

-- Returns all Real ID friends that are online on a character that is in the given guild
--
-- guildname: the name of the guild the characters have to be in
--
-- returns an array of BattleNet account session ids
function QLTalk:GetRemoteFriendsInGuild(guildName)
    local remoteFriends = {}

    numFriends = BNGetNumFriends();

    for i=1,numFriends do 
        local bnetIDAccount, accountName, battleTag, isBattleTagPresence, 
              characterName, bnetIDGameAccount, client, isOnline, lastOnline, 
              isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, 
              canSoR, isReferAFriend, canSummonFriend = BNGetFriendInfo(i);

        if (isOnline and (client == "WoW")) then
            local hasFocus, characterName, client, realmName, realmID, faction, 
                  race, class, guild, zoneName, level, gameText, broadcastText, 
                  broadcastTime, canSoR, toonID, bnetIDAccount, isGameAFK, 
                  isGameBusy = BNGetFriendGameAccountInfo(i, 1);
            
            QLTalk:Debug(
                "QLTalk:GetRemoteFriendsInGuild - found " 
                .. characterName 
                .. " - " 
                .. tostring(bnetIDGameAccount) 
                .. " - " 
                .. tostring(guild)
            );

            remoteFriends[#remoteFriends+1] = bnetIDGameAccount;
        end

    end

    return remoteFriends;
end

-- Send a message to all remote friends that are online on a character that is in the given guild 
--
-- guildname: the name of the guild the characters have to be in
-- msg: message to send
function QLTalk:SendMessageToRemoteFriends(guildName, msg)
    local remoteFriends = self.GetRemoteFriendsInGuild(guildName);

    for i=1,#remoteFriends do 
        chatMessage = QLTalk.ChatMessage:new{message=msg};
        --QLTalk:sendBNMessage(remoteFriends[i], chatMessage);
        QLTalk:SendMessageToLocalFriends(chatMessage);
    end
end