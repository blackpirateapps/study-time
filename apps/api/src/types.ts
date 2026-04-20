export type AuthUser = {
  uid: string;
  email?: string;
  name?: string;
};

export type AppBindings = {
  Variables: {
    user: AuthUser;
  };
};
