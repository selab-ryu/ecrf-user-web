/**
 * 
 */
package ecrf.user.subject.command.resource;

import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCResourceCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import java.io.PrintWriter;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserAttributes;
import ecrf.user.constants.attribute.ECRFUserSubjectAttributes;
import ecrf.user.service.SubjectLocalService;

/**
 * @author dev-ryu
 *
 */

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.SUBJECT,
	        "mvc.command.name="+ECRFUserMVCCommand.RESOURCE_CHECK_SERIAL_ID
	    },
	    service = MVCResourceCommand.class
)
public class CheckSerialIdResourceCommand extends BaseMVCResourceCommand {

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws Exception {
		
		long groupId = ParamUtil.getLong(resourceRequest, ECRFUserAttributes.GROUP_ID);
		String serialId = ParamUtil.getString(resourceRequest, ECRFUserSubjectAttributes.SERIAL_ID);
		
		boolean isDuplicated = false; 
		
		isDuplicated = _subjectLocalService.isDuplicatedSerialId(groupId, serialId);
		
		
		JSONObject result = JSONFactoryUtil.createJSONObject();
		result.put( "duplicate" , isDuplicated );
				
		PrintWriter pw = resourceResponse.getWriter();
		pw.write(result.toString());
		pw.flush();
		pw.close();

	}
	
	@Reference
	SubjectLocalService	_subjectLocalService;

}
