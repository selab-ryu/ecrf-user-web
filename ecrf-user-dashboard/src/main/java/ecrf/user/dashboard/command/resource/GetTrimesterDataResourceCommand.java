/**
 * 
 */
package ecrf.user.dashboard.command.resource;

import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.portlet.LiferayPortletMode;
import com.liferay.portal.kernel.portlet.LiferayWindowState;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCResourceCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.util.SXPortalUtil;
import com.sx.util.portlet.SXPortletURLUtil;

import java.io.PrintWriter;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import ecrf.user.constants.attribute.ECRFUserCRFAttributes;

/**
 * @author dev-ryu
 *
 */
public class GetTrimesterDataResourceCommand extends BaseMVCResourceCommand {

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws Exception {

		long crfId = ParamUtil.getLong(resourceRequest, ECRFUserCRFAttributes.CRF_ID);
		ThemeDisplay themeDisplay = (ThemeDisplay)resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		// get crf's data
		// search data, and aggregate by triemster
		// 
				
		JSONObject dataObj = JSONFactoryUtil.createJSONObject();
		
		
		PrintWriter pw = resourceResponse.getWriter();
		pw.write(dataObj.toString());
		pw.flush();
		pw.close();

	}

}
