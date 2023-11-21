package ecrf.user.main.display.context;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.Group;
import com.liferay.portal.kernel.model.GroupConstants;
import com.liferay.portal.kernel.service.GroupLocalServiceUtil;
import com.liferay.portal.kernel.service.UserGroupLocalServiceUtil;
import com.liferay.portal.kernel.service.UserLocalServiceUtil;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.ListUtil;
import com.liferay.portal.kernel.util.LocalizationUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.liferay.portlet.usersadmin.search.GroupSearch;
import com.liferay.portlet.usersadmin.search.GroupSearchTerms;
import com.liferay.users.admin.kernel.util.UsersAdminUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.LongStream;
import java.util.stream.Stream;

import javax.portlet.PortletURL;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.servlet.http.HttpServletRequest;

import ecrf.user.constants.ECRFUserWebKeys;

public class SiteDisplayContext {
	public SiteDisplayContext(RenderRequest renderRequest, RenderResponse renderResponse) {
		_renderRequest = renderRequest;
		_renderResponse = renderResponse;
		
		_httpServletRequest = PortalUtil.getHttpServletRequest(renderRequest);
		
		_log = LogFactoryUtil.getLog(this.getClass().getName());
	}
	
	public GroupSearch getMyGroupSearchContainer() {
		if(_myGroupSearch != null) {
			return _myGroupSearch;
		}
			
		GroupSearch groupSearch = _getGroupSearchContainer(true);
		_myGroupSearch = groupSearch;
		
		return _myGroupSearch;
	}
	
	public GroupSearch getAvailableGroupSearchContainer() {
		if(_availableGroupSearch != null) {
			return _availableGroupSearch;
		}
		
		GroupSearch groupSearch = _getGroupSearchContainer(false);
		_availableGroupSearch = groupSearch;
		
		return _availableGroupSearch;
	}
	
	private GroupSearch _getGroupSearchContainer(boolean isMySite) {
		ThemeDisplay themeDisplay = (ThemeDisplay)_renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		GroupSearch groupSearch = new GroupSearch(_renderRequest, getPortletURL());
		groupSearch.setOrderByCol(getOrderByCol());
		groupSearch.setOrderByType(getOrderByType());
		groupSearch.setOrderByComparator(UsersAdminUtil.getGroupOrderByComparator(getOrderByCol(), getOrderByType()));
		
		GroupSearchTerms searchTerms = (GroupSearchTerms)groupSearch.getSearchTerms(); 
		
		LinkedHashMap<String, Object> groupParams = new LinkedHashMap<>();
		
		groupParams.put("site", Boolean.TRUE);
		
		if(isMySite) {
			// my stie
			groupParams.put("usersGroups", themeDisplay.getUserId());
			groupParams.put("active", Boolean.TRUE);
		} else {
			// available site
			List<Integer> types = new ArrayList<>();

			types.add(GroupConstants.TYPE_SITE_OPEN);
			types.add(GroupConstants.TYPE_SITE_RESTRICTED);

			groupParams.put("types", types);
			groupParams.put("active", Boolean.TRUE);
		}	
		
		List<Group> results = new ArrayList<>(GroupLocalServiceUtil.search(
				themeDisplay.getCompanyId(), searchTerms.getKeywords(),
				groupParams, groupSearch.getStart(), groupSearch.getEnd(),
				groupSearch.getOrderByComparator()));
				
		// remove top parent site
		results.removeIf(group -> Validator.isNull(group.getParentGroup()));
		
		if(!isMySite) {
			results.removeIf(group -> GroupLocalServiceUtil.hasUserGroup(themeDisplay.getUserId(), group.getGroupId()));
		}
		
		groupSearch.setResults(results);
		groupSearch.setTotal(GroupLocalServiceUtil.searchCount(
				themeDisplay.getCompanyId(), searchTerms.getKeywords(),
				groupParams));
		
		return groupSearch;
	}
	
	public String getDisplayStyle() {
		if (Validator.isNotNull(_displayStyle)) {
			return _displayStyle;
		}

		_displayStyle = ParamUtil.getString(_httpServletRequest, ECRFUserWebKeys.DISPLAY_STYLE, "descriptive"); 

		return _displayStyle;
	}
	
	public String getOrderByCol() {
		if (Validator.isNotNull(_orderByCol)) {
			return _orderByCol;
		}
		
		_orderByCol = ParamUtil.getString(_httpServletRequest, ECRFUserWebKeys.ORDER_BY_COL, "name"); 

		return _orderByCol;
	}
	
	public String getOrderByType() {
		if (Validator.isNotNull(_orderByType)) {
			return _orderByType;
		}
		
		_orderByType = ParamUtil.getString(_httpServletRequest, ECRFUserWebKeys.ORDER_BY_TYPE, "asc");
		
		return _orderByType;
	}
	
	public PortletURL getPortletURL() {
		PortletURL portletURL = _renderResponse.createRenderURL();
		portletURL.setParameter(ECRFUserWebKeys.DISPLAY_STYLE, getDisplayStyle());
		
		return portletURL;		
	}
	
	public int getGroupUsersCount(long groupId) {
		if(_groupUsersCounts != null) {
			return GetterUtil.getInteger(_groupUsersCounts.get(groupId));
		}
		
		ThemeDisplay themeDisplay = (ThemeDisplay)_renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		GroupSearch myGroupSearch = _getGroupSearchContainer(true);
		GroupSearch availableGroupSearch = _getGroupSearchContainer(false);
		
		long[] myGroupIds = ListUtil.toLongArray(myGroupSearch.getResults(), Group.GROUP_ID_ACCESSOR);
		long[] availableGroupIds = ListUtil.toLongArray(availableGroupSearch.getResults(), Group.GROUP_ID_ACCESSOR);
		long[] groupIds = mergeUniqueValues(myGroupIds, availableGroupIds);
		
		_groupUsersCounts = UserLocalServiceUtil.searchCounts(themeDisplay.getCompanyId(), WorkflowConstants.STATUS_APPROVED, groupIds);
		
		return GetterUtil.getInteger(_groupUsersCounts.get(groupId));
	}
	
	public int getTotalItems(boolean isMySite) {
		GroupSearch groupSearch = null;
		if(isMySite) getMyGroupSearchContainer();
		else getAvailableGroupSearchContainer();
		return groupSearch.getTotal();
	}
	
	private long[] mergeUniqueValues(long[] arr1, long[] arr2) {
		LongStream stream = LongStream.concat(LongStream.of(arr1), LongStream.of(arr2));
		return stream.distinct().sorted().toArray();
	}
	
	private String _displayStyle;
	private GroupSearch _myGroupSearch;
	private GroupSearch _availableGroupSearch;
	private Map<Long, Integer> _groupUsersCounts;
	private final HttpServletRequest _httpServletRequest;
	private String _orderByCol;
	private String _orderByType;
	private final RenderRequest _renderRequest;
	private final RenderResponse _renderResponse;
	
	private Log _log;
}
