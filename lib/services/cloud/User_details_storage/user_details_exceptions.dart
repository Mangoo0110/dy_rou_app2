
class UserDetailsStorageExceptions implements Exception {
  const UserDetailsStorageExceptions();
}
class CouldNotGetUserDetailsException extends UserDetailsStorageExceptions{}

class CouldNotUpdateUserDetailsException extends UserDetailsStorageExceptions{}

class CouldNotUpdateUserImageException extends UserDetailsStorageExceptions{}

class CouldNotUpdateUserNameException extends UserDetailsStorageExceptions{}

class CouldNotUpdateUserEmailException extends UserDetailsStorageExceptions{}

class CouldNotUpdateUserFriendsException extends UserDetailsStorageExceptions{}

class CouldNotUpdateUserNotAcceptedFriendsException extends UserDetailsStorageExceptions{}

class CouldNotUpdateUserRequestedFriendsException extends UserDetailsStorageExceptions{}

class CouldNotCreateNewUserDetailsException extends UserDetailsStorageExceptions{}

class CouldDeleteException extends UserDetailsStorageExceptions{}