module.exports =

    member :
      following :
        """
          START group=node:koding(id={groupId})
          MATCH group-[r:member]->members-[:follower]->currentUser
          WHERE currentUser.id = {currentUserId}
          RETURN members
          ORDER BY {orderByQuery} DESC
          SKIP {skipCount}
          LIMIT {limitCount}
        """
      follower  :
        """
          START group=node:koding(id={groupId})
          MATCH group-[r:member]->members<-[:follower]-currentUser
          WHERE currentUser.id = {currentUserId}
          RETURN members
          ORDER BY {orderByQuery} DESC
          SKIP {skipCount}
          LIMIT {limitCount}
        """
      list      :
        """
          START group=node:koding(id={groupId})
          MATCH group-[r:member]->members
          RETURN members
          ORDER BY {orderByQuery} DESC
          SKIP {skipCount}
          LIMIT {limitCount}
        """
    bucket :
      newMembers :
        """
          START group=node:koding(id={groupId})
          MATCH group-[r:member]->members
          WHERE r.createdAtEpoch < {to}
          RETURN members
          ORDER BY r.createdAtEpoch DESC
          LIMIT 20
        """
      newInstallations :
        """
          START group=node:koding(id={groupId})
          MATCH group-[:member]->users<-[r:user]-apps
          WHERE apps.name="JApp"
          AND r.createdAtEpoch < {to}
          RETURN users, apps, r
          ORDER BY r.createdAtEpoch DESC
          LIMIT 20
        """
      newUserFollows :
        """
          START group=node:koding(id={groupId})
          MATCH group-[:member]->followees<-[r:follower]-follower
          WHERE follower<-[:member]-group
          AND r.createdAtEpoch < {to}
          RETURN r,followees, follower
          ORDER BY r.createdAtEpoch DESC
          LIMIT 20
        """
      newTagFollows :
        """
          START koding=node:koding(id={groupId})
          MATCH koding-[:member]->followees<-[r:follower]-follower
          WHERE follower.name="JTag"
            AND follower.group = {groupName}
            AND r.createdAtEpoch < {to}
          RETURN r,followees, follower
          ORDER BY r.createdAtEpoch DESC
          LIMIT 20
        """
    activity :
      public :(facetQuery="",groupFilter="")->
        """
          START group=node:koding(id={groupId})
          MATCH group-[:member]->members<-[:author]-content
          WHERE content.`meta.createdAtEpoch` < {to}
          #{facetQuery}
          #{groupFilter}
          RETURN content
          ORDER BY content.`meta.createdAtEpoch` DESC
          LIMIT {limitCount}
        """

      following:(facet="", timeQuery="")->
        """
          START member=node:koding(id={userId})
          MATCH member<-[:follower]-myfollowees-[:author]-content
          WHERE myfollowees.name="JAccount"
          AND content.group = {groupName}
          #{facet}
          #{timeQuery}
          RETURN distinct content
          ORDER BY content.`meta.createdAtEpoch` DESC
          LIMIT {limitCount}
        """
      
      profilePage: (options)->
        """
          start koding=node:koding(id={userId})
          MATCH koding<-[:author]-content
          WHERE
          content.`meta.createdAtEpoch` < {to}
          #{options.facetQuery}
          return distinct content
          order by {orderBy} DESC
          LIMIT {limitCount}
        """

    invitation :
      list     :(status, timestampQuery="", searchQuery="")->
        """
          START group=node:koding(id={groupId})
          MATCH group-[r:owner]->groupOwnedNodes
          WHERE groupOwnedNodes.name = 'JInvitationRequest'
          AND groupOwnedNodes.status IN #{status}
          #{timestampQuery}
          #{searchQuery}
          RETURN groupOwnedNodes
          ORDER BY groupOwnedNodes.`meta.createdAtEpoch`
          LIMIT {limitCount}
        """

