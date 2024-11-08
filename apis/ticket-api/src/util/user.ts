import type { SupabaseClient, User } from "@supabase/supabase-js";
import type { Database } from "supabase-types";

export async function getUser(
	authorizationHeader: string,
	supabase: SupabaseClient<Database>,
): Promise<User | null> {
	const jwt = authorizationHeader.replace("Bearer ", "");
	console.log(jwt);
	const {
		data: { user },
	} = await supabase.auth.getUser(jwt);

	return user;
}

export async function getUserWithProfile(
	authorizationHeader: string,
	supabase: SupabaseClient<Database>,
): Promise<
	| {
			success: true;
			user: User;
			profile: Database["public"]["Tables"]["profiles"]["Row"];
	  }
	| {
			success: false;
			error: string;
	  }
> {
	const user = await getUser(authorizationHeader, supabase);
	if (!user) {
		return { success: false, error: "User not found" };
	}
	const { data: profile, error } = await supabase
		.from("profiles")
		.select("*")
		.eq("id", user.id)
		.single();
	if (error) {
		return { success: false, error: error.message };
	}
	return {
		success: true,
		user,
		profile,
	};
}
