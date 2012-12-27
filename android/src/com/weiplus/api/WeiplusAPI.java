package com.weiplus.api;

public abstract class WeiplusAPI {
    /**
     */
	public static final String API_SERVER = "https://open.weibo.cn/2";
	/**
	 * post请求方式
	 */
	public static final String HTTPMETHOD_POST = "POST";
	/**
	 * get请求方式
	 */
	public static final String HTTPMETHOD_GET = "GET";
	private WeiplusAccessToken weiplusAccessToken;
	private String accessToken;
	/**
	 * 构造函数，使用各个API接口提供的服务前必须先获取WeiplusAccessToken
	 * @param accesssToken WeiplusAccessToken
	 */
	public WeiplusAPI(WeiplusAccessToken oauth2AccessToken){
	    this.weiplusAccessToken=oauth2AccessToken;
	    if(weiplusAccessToken!=null){
	        accessToken=weiplusAccessToken.getToken();
	    }
	   
	}
	public enum FEATURE {
		ALL, ORIGINAL, PICTURE, VIDEO, MUSICE
	}

	public enum SRC_FILTER {
		ALL, WEIBO, WEIQUN
	}

	public enum TYPE_FILTER {
		ALL, ORIGAL
	}

	public enum AUTHOR_FILTER {
		ALL, ATTENTIONS, STRANGER
	}

	public enum TYPE {
		STATUSES, COMMENTS, MESSAGE
	}

	public enum EMOTION_TYPE {
		FACE, ANI, CARTOON
	}

	public enum LANGUAGE {
		cnname, twname
	}

	public enum SCHOOL_TYPE {
		COLLEGE, SENIOR, TECHNICAL, JUNIOR, PRIMARY
	}

	public enum CAPITAL {
		A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
	}

	public enum FRIEND_TYPE {
		ATTENTIONS, FELLOWS
	}

	public enum RANGE {
		ATTENTIONS, ATTENTION_TAGS, ALL
	}

	public enum USER_CATEGORY {
		DEFAULT, ent, hk_famous, model, cooking, sports, finance, tech, singer, writer, moderator, medium, stockplayer
	}

	public enum STATUSES_TYPE {
		ENTERTAINMENT, FUNNY, BEAUTY, VIDEO, CONSTELLATION, LOVELY, FASHION, CARS, CATE, MUSIC
	}

	public enum COUNT_TYPE {
	    /**
	     * 新微博数
	     */
		STATUS, 
		/**
		 * 新粉丝数
		 */
		FOLLOWER, 
		/**
		 * 新评论数
		 */
		CMT, 
		/**
		 * 新私信数
		 */
		DM, 
		/**
		 * 新提及我的微博数
		 */
		MENTION_STATUS, 
		/**
		 * 新提及我的评论数
		 */
		MENTION_CMT
	}
	/**
	 * 分类
	 *
	 */
	public enum SORT {
	    Oauth2AccessToken, 
	    SORT_AROUND
	}

	public enum SORT2 {
		SORT_BY_TIME, SORT_BY_HOT
	}
	
	public enum SORT3 {
		SORT_BY_TIME, SORT_BY_DISTENCE
	}
	
	public enum COMMENTS_TYPE {
		NONE, CUR_STATUSES, ORIGAL_STATUSES, BOTH
	}
	
	protected void request( final String url, final WeiplusParameters params,
			final String httpMethod, RequestListener listener) {
		params.add("access_token", accessToken);
		AsyncRunner.request(url, params, httpMethod, listener);
	}
}
