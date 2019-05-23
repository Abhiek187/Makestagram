//
//  FollowService.swift
//  Makestagram
//
//  Created by Basanta Chaudhuri on 5/21/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FollowService {
    private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : true,
                          "following/\(currentUID)/\(user.uid)" : true]
        
        let ref = DatabaseReference.toLocation(.root)
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            }
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            
            let followingCountRef = DatabaseReference.toLocation(.followingCount(uid: currentUID))
            followingCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount + 1
                
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            let followerCountRef = DatabaseReference.toLocation(.followerCount(uid: user.uid))
            followerCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount + 1
                
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            UserService.posts(for: user) { (posts) in
                let postKeys = posts.compactMap { $0.key }
                
                var followData = [String : Any]()
                let timelinePostDict = ["poster_uid" : user.uid]
                postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main) {
                success(true)
            }
        }
    }
    
    private static func unfollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
        // http://stackoverflow.com/questions/38462074/using-updatechildvalues-to-delete-from-firebase
        let followData = ["followers/\(user.uid)/\(currentUID)" : NSNull(),
                          "following/\(currentUID)/\(user.uid)" : NSNull()]
        
        let ref = DatabaseReference.toLocation(.root)
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            }
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            let followingCountRef = DatabaseReference.toLocation(.followingCount(uid: currentUID))
            followingCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount - 1
                
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            let followerCountRef = DatabaseReference.toLocation(.followerCount(uid: user.uid))
            followerCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount - 1
                
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            UserService.posts(for: user, completion: { (posts) in
                var unfollowData = [String : Any]()
                let postsKeys = posts.compactMap { $0.key }
                postsKeys.forEach {
                    // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
                    unfollowData["timeline/\(currentUID)/\($0)"] = NSNull()
                }
                
                ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    dispatchGroup.leave()
                })
            })
            
            dispatchGroup.notify(queue: .main) {
                success(true)
            }
        }
    }
    
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
        if isFollowing {
            followUser(followee, forCurrentUserWithSuccess: success)
        } else {
            unfollowUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    
    static func isUserFollowed(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let ref = DatabaseReference.toLocation(.followers(uid: user.uid))
        
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}
