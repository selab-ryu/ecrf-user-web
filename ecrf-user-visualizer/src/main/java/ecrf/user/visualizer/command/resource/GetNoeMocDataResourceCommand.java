/**
 * 
 */
package ecrf.user.visualizer.command.resource;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCResourceCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.service.DataTypeLocalService;

import java.io.PrintWriter;
import java.util.List;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.attribute.ECRFUserCRFAttributes;
import ecrf.user.model.CRF;
import ecrf.user.model.LinkCRF;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.visualizer.constants.ECRFVisualizerMVCCommand;
import ecrf.user.visualizer.constants.ECRFVisualizerPortletKeys;
import ecrf.user.visualizer.util.ECRFUserVisualizerUtil;

/**
 * @author dev-ryu
 *
 */

@Component(
    immediate = true,
    property = {
    		"javax.portlet.name=" + ECRFVisualizerPortletKeys.ECRFVISUALIZER,
            "mvc.command.name="+ECRFVisualizerMVCCommand.RESOURCE_GET_NOE_MOC
    },
    service = MVCResourceCommand.class
)

public class GetNoeMocDataResourceCommand extends BaseMVCResourceCommand {

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws Exception {
		
		long crfId = ParamUtil.getLong(resourceRequest, ECRFUserCRFAttributes.CRF_ID);
		ThemeDisplay themeDisplay = (ThemeDisplay)resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		// get CRF
		CRF crf = _crfLocalService.getCRF(crfId);
		//_log.info("crf id : " + String.valueOf(crfId));
		
		JSONObject dataObj = JSONFactoryUtil.createJSONObject();
		
		// get datatype structure and set to form JSON Object
		String formStr = _dataTypeLocalService.getDataTypeStructure(crf.getDatatypeId());
		JSONObject formObj = null;
		try {
			formObj = JSONFactoryUtil.createJSONObject(formStr);
		} catch (Exception e) {
			e.printStackTrace();
		}
		dataObj.put("form", formObj);
		
		// get crf's all data
		List<LinkCRF> linkList = _linkCRFLocalService.getLinkCRFByG_C(themeDisplay.getScopeGroupId(), crfId);
		//_log.info("link list size : " + linkList.size());
		
		// trimester count {total, 1st, 2nd, 3rd, 4th}
		Integer[] trimesterCount = {0,0,0,0,0};
				
		JSONArray sdArr = JSONFactoryUtil.createJSONArray();
		
		// search data, and aggregate by triemster
		for(LinkCRF link : linkList) {
			long sdId = link.getStructuredDataId();
			
			// get Structured Data and check trimester
			if(Validator.isNotNull(sdId)) {
				String sdStr = _dataTypeLocalService.getStructuredData(sdId);
				
				JSONObject sdObj = null;
				
				// create json object
				try {
					sdObj = JSONFactoryUtil.createJSONObject(sdStr);
				} catch (Exception e) {
					e.printStackTrace();
				}
				
				// add sd obj to sd arr
				if(Validator.isNotNull(sdObj)) {
					sdArr.put(sdObj);
					trimesterCount[0]++;	// valid data count

					// aggregate trimester count
					if(sdObj.has("trimester")) {
						JSONArray trimester = sdObj.getJSONArray("trimester");
						String trimesterValStr = trimester.getString(0);
						int trimesterVal = Integer.valueOf(trimesterValStr);
						
						trimesterCount[trimesterVal]++;
					}
				}
			}
		}
		/* log count
		for(Integer count : trimesterCount) {
			_log.info(count);
		}
		*/
		
		// add count to data obj
		JSONArray countArr = null;
		try {
			countArr = JSONFactoryUtil.createJSONArray(trimesterCount);
		} catch(Exception e) {
			e.printStackTrace();
		}

		// add group to data obj
		
		JSONArray groupArr = null;
		try {
			groupArr = ECRFUserVisualizerUtil.getVisualGroup("NoE_Moc");
		} catch(Exception e) {
			e.printStackTrace();
		}
				
		// add count arr and sd arr to data obj
		dataObj.put("count", countArr);
		dataObj.put("data", sdArr);
		dataObj.put("group", groupArr);

		// write data obj to response
		PrintWriter pw = resourceResponse.getWriter();
		pw.write(dataObj.toString());
		pw.flush();
		pw.close();
	}
	
	private Log _log = LogFactoryUtil.getLog(GetNoeMocDataResourceCommand.class);
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;

	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;	
}