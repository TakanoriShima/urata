class PostsRegionController < ApplicationController
  
  before_action :authenticate_user!, except:[:index]
  before_action :user_profile_nil?, except:[:index]
  
  def new
    @post = Post.new
    @category_resources = CategoryResource.all
    @category_issues = CategoryIssue.all
    @category_markets = CategoryMarket.all
    @category_features = CategoryFeature.all
    @category_realizabilities = CategoryRealizability.all
    @user_profile = current_user.user_profile
    @post_type_flag = 1
    @profile_type1_flag = true
  end
  
  def create
    @post = Post.new(post_params)
    @user_profile = current_user.user_profile
    
    category_resources_ids = params[:category_resource_id]
    category_issues_ids = params[:category_issue_id]
    category_markets_ids = params[:category_market_id]
    category_features_ids = params[:category_feature_id]
    category_realizabilities_ids = params[:category_realizability_id]
    # puts "ここ"
    # p category_resources_ids
    
    if @post.save
     if category_resources_ids.present?
      category_resources_ids.each do |category_resources_id|
        category_resources = @post.post_category_resources.build(category_resource_id: category_resources_id)
        puts "ここ"
        p category_resources
        category_resources.save
       end
     end
     
     if category_issues_ids.present?
      category_issues_ids.each do |category_issues_id|
        category_issues = @post.post_category_issues.build(category_issue_id: category_issues_id)
        category_issues.save
       end
     end
     
     if category_markets_ids.present?
      category_markets_ids.each do |category_markets_id|
        category_markets = @post.post_category_markets.build(category_market_id: category_markets_id)
        category_markets.save
      end  
     end
     
     if category_features_ids.present?
       category_features_ids.each do |category_features_id|
        category_features = @post.post_category_features.build(category_feature_id: category_features_id)
        category_features.save
       end   
     end
     
     if category_realizabilities_ids.present?
       category_realizabilities_ids.each do |category_realizabilities_id|
         category_realizabilities = @post.post_category_realizabilities.build(category_realizability_id: category_realizabilities_id)
         category_realizabilities.save
       end
     end
     
      redirect_to @post, action: "show", id: @post.id, notice:"登録が完了しました"
    else
      render "new", status: :unprocessable_entity, notice:"登録に失敗しました"  
      #空欄以外で登録失敗ってある？空欄だと画面が遷移しない。
    end
  end
  
  def index
    @category_resources = CategoryResource.all
    @category_issues = CategoryIssue.all
    @category_markets = CategoryMarket.all
    @category_features = CategoryFeature.all
    @category_realizabilities = CategoryRealizability.all
    @category_about_regions = CategoryAboutRegion.all
    @category_incubations = CategoryIncubation.all
    @category_immigration_supports = CategoryImmigrationSupport.all
    @post_type = params[:post_type]
    @prefecture = params[:prefecture]
    @keyword = params[:keyword]
    category_resource_ids = params[:category_resource_id]
    category_issue_ids = params[:category_issue_id]
    category_market_ids = params[:category_market_id]
    category_feature_ids = params[:category_feature_id]
    category_realizability_ids = params[:category_realizability_id]
    category_about_region_ids = params[:category_about_region_id]
    category_incubation_ids = params[:category_incubation_id]
    category_immigration_support_ids = params[:category_immigration_support_id]
    @search_type = params[:search_type]
    # @posts = []
    #@posts_post_type_ids = []
    #@posts_post_type_keyword = []
    # @posts_post_type_keyword_prefecture = []
    #@posts_post_type_keyword_prefecture_ids = []
    @category_resource_posts = []
    @category_issue_posts = []
    @category_market_posts = []
    @category_feature_posts = []
    @category_realizability_posts = []
    @category_about_region_profiles = []
    @category_incubation_profiles = []
    @category_immigration_support_profiles = []
    @category_resource_posts_all = []
    @category_issue_posts_all = []
    @category_market_posts_all = []
    @category_feature_posts_all = []
    @category_realizability_posts_all = []
    @category_about_region_profiles_all = []
    @category_incubation_profiles_all = []
    @category_immigration_support_profiles_all = []
    @posts_tag = []
    @post_tag_ids = []
    @profiles_tag = []
    @profile_tag_ids = []
    @post_profile_tag_ids = []
    @check_flags_category_resources = []
    @check_flags_category_issues = []
    @check_flags_category_markets = []
    @check_flags_category_features =[]
    @check_flags_category_realizabilities =[]
    @check_flags_category_about_regions =[]
    @check_flags_ccategory_incubations =[]
    @check_flags_category_immigration_supports =[]
    
    #「地域側投稿」のみ抽出
    @posts_post_type = Post.where(post_type: 1)
    @posts_post_type_ids = @posts_post_type.pluck(:id)
    
    #キーワードが入力された場合
    if @keyword.present?
     keyword = '%' + @keyword + '%'
     @posts_post_type_keyword = Post.where("title like ?", keyword).or(Post.where("body1 like ?", keyword)).where(id: @posts_post_type_ids)
    else
     @posts_post_type_keyword = @posts_post_type
    end 
      
    #「都道府県」が選択された場合
    if @prefecture.present?
      @post_prefecture = Post.where(prefecture: @prefecture)
      @posts_post_type_keyword_prefecture = @posts_post_type_keyword & @post_prefecture 
    else
      @posts_post_type_keyword_prefecture = @posts_post_type_keyword
    end 
    
    #「投稿タイプ」と「キーワード」と「都道府県」の条件を満たす投稿のid
    @posts_post_type_keyword_prefecture_ids = @posts_post_type_keyword_prefecture.pluck(:id)
    
    #タグによる検索
    #「地域資源」でチェックされている項目を含む投稿
    if category_resource_ids.present?
      category_resource_ids.each do |category_resource_id|  
        @category_resource_posts = Post.joins(:post_category_resources).where(post_category_resources: {category_resource_id: category_resource_id})
        @category_resource_posts_all.concat(@category_resource_posts)
      end
      @category_resource_posts_ids = @category_resource_posts_all.pluck(:id).uniq
    end  
  
    #「地域課題」でチェックされている項目を含む投稿
    if category_issue_ids.present?
      category_issue_ids.each do |category_issue_id|  
        @category_issue_posts = Post.joins(:post_category_issues).where(post_category_issues: {category_issue_id: category_issue_id})
        @category_issue_posts_all.concat(@category_issue_posts)
      end
      @category_issue_posts_ids = @category_issue_posts_all.pluck(:id).uniq
    end 
    
    #「需要」でチェックされている項目を含む投稿
    if category_market_ids.present?
      category_market_ids.each do |category_market_id|  
        @category_market_posts = Post.joins(:post_category_markets).where(post_category_markets: {category_market_id: category_market_id})
        @category_issue_posts_all.concat(@category_market_posts)
      end
      @category_market_posts_ids = @category_market_posts_all.pluck(:id).uniq
    end  
    
    #「地域の特色」でチェックされている項目を含む投稿
    if category_feature_ids.present?
      category_feature_ids.each do |category_feature_id|  
        @category_feature_posts = Post.joins(:post_category_features).where(post_category_features: {category_feature_id: category_feature_id})
        @category_feature_posts_all.concat(@category_feature_posts)
      end
      @category_feature_posts_ids = @category_feature_posts_all.pluck(:id).uniq
    end
    puts 'ここだよ'
    p @category_feature_posts_ids
    
    #「実現可能性」でチェックされている項目を含む投稿
    if category_realizability_ids.present?
      category_realizability_ids.each do |category_realizability_id|  
        @category_realizability_posts = Post.joins(:post_category_realizabilities).where(post_category_realizabilities: {category_realizability_id: category_realizability_id})
        @category_realizability_posts_all.concat(@category_realizability_posts)
      end
      @category_realizability_posts_ids = @category_realizability_posts_all.pluck(:id).uniq
    end
    
    #「地域について」でチェックされている項目を含む投稿
    if category_about_region_ids.present?
     category_about_region_ids.each do |category_about_region_id|
      @category_about_region_profiles = UserProfile.joins(:profile_category_about_regions).where(profile_category_about_regions: {category_about_region_id: category_about_region_id})
      @category_about_region_profiles_all.concat(@category_about_region_profiles)
     end 
    end
    
    #「起業支援」でチェックされている項目を含む投稿
    if category_incubation_ids.present?
     category_incubation_ids.each do |category_incubation_id|
      @category_incubation_profiles = UserProfile.joins(:profile_category_incubations).where(profile_category_incubations: {category_incubation_id: category_incubation_id})
      @category_incubation_profiles_all.concat(@category_incubation_profiles)
     end 
    end
    
    #「移住支援」でチェックされている項目を含む投稿
    if category_immigration_support_ids.present?
     category_immigration_support_ids.each do |category_immigration_support_id|
      @category_immigration_support_profiles = UserProfile.joins(:profile_category_immigration_supports).where(profile_category_immigration_supports: {category_immigration_support_id: category_immigration_support_id})
      @category_immigration_support_profiles_all.concat(@category_immigration_support_profiles)
     end 
    end
         
    #　タグ「地域資源」「地域課題」「需要」「地域の特色」「実現可能性」「地域について」「起業支援」「移住支援」の各項目についてOR検索  
    if @search_type == "1"   
      #　タグ「地域資源」「地域課題」「需要」「地域の特色」「実現可能性「地域について」「起業支援」「移住支援」」が一つも選択されていない
      if category_resource_ids.nil? && category_issue_ids.nil? && category_market_ids.nil? && category_feature_ids.nil? && category_realizability_ids.nil? && category_about_region_ids.nil? && category_incubation_ids.nil? && category_immigration_support_ids.nil?
        @posts = @posts_post_type_keyword_prefecture
      else
       #投稿のタグでの絞り込み
       @posts_tag.concat(@category_resource_posts, @category_issue_posts, @category_market_posts, @category_feature_posts, @category_realizability_posts)
       
       #プロフィールのタグでの絞り込み
       @profiles_tag.concat(@category_about_region_profiles_all, @category_incubation_profiles_all, @category_immigration_support_profiles_all)
       @profile_tag_ids = @profiles_tag.pluck(:id)
       @posts_user = User.where(id: @profile_tag_ids)
       @posts_profile_tag = Post.where(user_id: @posts_user)
       @posts_tag.concat(@posts_profile_tag)
       
       @posts = @posts_tag & @posts_post_type_keyword_prefecture
      end
    
    #　タグ「地域資源」「地域課題」「需要」「地域の特色」「実現可能性」「地域について」「起業支援」「移住支援」の各項目についてAND検索  
    elsif @search_type == "2"
      #　タグ「地域資源」「地域課題」「需要」「地域の特色」「実現可能性「地域について」「起業支援」「移住支援」」が一つも選択されていない
      if category_resource_ids.nil? && category_issue_ids.nil? && category_market_ids.nil? && category_feature_ids.nil? && category_realizability_ids.nil? && category_about_region_ids.nil? && category_incubation_ids.nil? && category_immigration_support_ids.nil?
        @posts = @posts_post_type_keyword_prefecture
      else
        #「地域資源」のチェックボックスが一つでもチェックされた場合
        if category_resource_ids.present?
          @post_tag_ids = @category_resource_posts_ids
        end
        
        #「地域課題」のチェックボックスが一つでもチェックされた場合
        if category_issue_ids.present?
         if category_resource_ids.nil?
          @post_tag_ids = @category_issue_posts_ids
         else  
          @post_tag_ids = @post_tag_ids & @category_issue_posts_ids
         end
        end
        
        #「需要」のチェックボックスが一つでもチェックされた場合
        if category_market_ids.present?
         if category_resource_ids.nil? & category_issue_ids.nil?
          @post_tag_ids = @category_market_posts_ids
         else  
          @post_tag_ids = @post_tag_ids & @category_market_posts_ids
         end
        end    
        
        #「地域の特色」のチェックボックスが一つでもチェックされた場合
        if category_feature_ids.present?
         if category_resource_ids.nil? & category_issue_ids.nil? & category_market_ids.nil?
          @post_tag_ids = @category_feature_posts_ids
         else  
          @post_tag_ids = @post_tag_ids & @category_feature_posts_ids
         end
        end
        
        #「実現可能性」のチェックボックスが一つでもチェックされた場合
        if category_realizability_ids.present?
         if category_resource_ids.nil? & category_issue_ids.nil? & category_market_ids.nil? & category_feature_ids.nil?
          @post_tag_ids = @category_realizability_posts_ids
         else  
          @post_tag_ids = @post_tag_ids & @category_realizability_posts_ids
         end
        end
        
        #プロフィールでの絞り込み
        if category_about_region_ids.nil? && category_incubation_ids.nil? && category_immigration_support_ids.nil?
         @posts_tag_ids = @posts_tag_ids
        else
         
         #「地域について」のチェックボックスが一つでもチェックされた場合
         if category_about_region_ids.present?
          @profiles_tag = @category_about_region_profiles_all
         end
         
         #「起業支援」のチェックボックスが一つでもチェックされた場合
         if category_incubation_ids.present?
          if category_about_region_ids.nil?
           @profiles_tag = @category_incubation_profiles_all
          else
           @profiles_tag = @profiles_tag & @category_incubation_profiles_all
          end
         end
         
         #「移住支援」のチェックボックスが一つでもチェックされた場合
         if category_immigration_support_ids.present?
          if category_about_region_ids.nil? && category_incubation_ids.nil?
           @profiles_tag = @category_immigration_support_profiles_all
          else
           @profiles_tag = @profiles_tag & @category_immigration_support_profiles_all
          end
         end
         
         @profile_tag_ids = @profiles_tag.pluck(:id)
         @posts_user = User.where(id: @profile_tag_ids)
         @posts_profile_tag = Post.where(user_id: @posts_user)
         @post_profile_tag_ids = @posts_profile_tag.pluck(:id)
         if @post_tag_ids.empty?
          @post_tag_ids = @post_profile_tag_ids
         else
          @post_tag_ids = @post_tag_ids & @post_profile_tag_ids
         end
        end 
        
        @posts_tag = Post.where(id: @post_tag_ids)
        @posts = @posts_tag & @posts_post_type_keyword_prefecture
      end
      
    #検索条件をクリアした場合  
    else
      @posts = Post.where(post_type: 1)
    end
    
 # チェック済のボックスにチェックを入れて検索結果を表示するため。
   if category_resource_ids.present?
    @category_resources.each_with_index do |category_resource, index|
      if category_resource_ids.include?(category_resource.id.to_s)
       @check_flags_category_resources[index] = true
      else
       @check_flags_category_resources[index] = false
      end
    end
   end
   
   if category_issue_ids.present?
    @category_issues.each_with_index do |category_issue, index|
      if category_issue_ids.include?(category_issue.id.to_s)
       @check_flags_category_issues[index] = true
      else
       @check_flags_category_issues[index] = false
      end
    end
   end
   
   if category_market_ids.present?
    @category_markets.each_with_index do |category_market, index|
      if category_market_ids.include?(category_market.id.to_s)
       @check_flags_category_markets[index] = true
      else
       @check_flags_category_markets[index] = false
      end
    end
   end
   
   if category_feature_ids.present?
     @category_features.each_with_index do |category_feature, index|
      if category_feature_ids.include?(category_feature.id.to_s)
       @check_flags_category_features[index] = true
      else
       @check_flags_category_features[index] = false
      end
    end
   end
   
   if category_realizability_ids.present?
     @category_realizabilities.each_with_index do |category_realizability, index|
      if category_realizability_ids.include?(category_realizability.id.to_s)
       @check_flags_category_realizabilities[index] = true
      else
       @check_flags_category_realizabilities[index] = false
      end
    end
   end
   
   if category_about_region_ids.present?
     @category_about_regions.each_with_index do |category_about_region, index|
      if category_about_region_ids.include?(category_about_region.id.to_s)
       @check_flags_category_about_regions[index] = true
      else
       @check_flags_category_about_regions[index] = false
      end
    end
   end
   
   if category_incubation_ids.present?
     @category_incubations.each_with_index do |category_incubation, index|
      if category_incubation_ids.include?(category_incubation.id.to_s)
       @check_flags_category_incubations[index] = true
      else
       @check_flags_category_incubations[index] = false
      end
    end
   end
   
   if category_immigration_support_ids.present?
     @category_immigration_supports.each_with_index do |category_immigration_support, index|
      if category_immigration_support_ids.include?(category_immigration_support.id.to_s)
       @check_flags_category_immigration_supports[index] = true
      else
       @check_flags_category_immigration_supports[index] = false
      end
    end
   end
  end
  
  private
  def post_params
   params.require(:post).permit(:user_id, :post_type, :title, :prefecture, :city, :body1, :body2, :feature, :attachment, :realizability, :earnest, :public_status_id, images: [])
  end

  def ensure_user
    @post = Post.find(params[:id])
    unless @post.user_id == current_user.id
      redirect_to "show", id: @post.id
    end
  end
  
  def user_profile_nil?
    if current_user.user_profile.nil?
     flash.now[:notice] = "先にプロフィール登録をお済ませください"
     render template: "user_profiles/new"
    end 
  end  
end
