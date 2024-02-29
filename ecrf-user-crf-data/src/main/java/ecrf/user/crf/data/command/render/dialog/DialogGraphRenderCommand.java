package ecrf.user.crf.data.command.render.dialog;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import java.util.List;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.service.CRFLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_DIALOG_CRF_DATA_GRAPH,
	    },
	    service = MVCRenderCommand.class
	)
public class DialogGraphRenderCommand implements MVCRenderCommand{
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		_log.info("Render Graph popup");
		
		String termName = ParamUtil.getString(renderRequest, "termName");
		_log.info(termName);
		
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID);
		long dataTypeId = _crfLocalService.getDataTypeId(crfId);
		
		List<StructuredData> sd = _dataTypeLocalService.getStructuredDatas(dataTypeId);
		String crfForm = "";
		JSONArray crfFormArr = null;
		
		try {
			crfForm = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
			crfFormArr = JSONFactoryUtil.createJSONArray(JSONFactoryUtil.createJSONObject(crfForm).getString("terms"));
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		JSONObject compObj = JSONFactoryUtil.createJSONObject();
		for(int i = 0; i < crfFormArr.length(); i++) {
			if(crfFormArr.getJSONObject(i).getString("termName").equals(termName)) {
				compObj = crfFormArr.getJSONObject(i);
			}
		}
		
		if(compObj.getString("termType").equals("List")) {
			_log.info(termName);
			JSONArray options = compObj.getJSONArray("options");
			String[] datas = new String[options.length()];
			String[] values = new String[options.length()];
			int[] valueCounts = new int[options.length()];
			for(int j = 0; j < options.length(); j++) {
				datas[j] = options.getJSONObject(j).getJSONObject("label").getString("en_US");
				values[j] = options.getJSONObject(j).getString("value");
				valueCounts[j] = 0;
			}
			for(int k = 0; k < sd.size(); k++) {
				String answers = sd.get(k).getStructuredData();
				JSONObject ansObj = null;
				try {
					ansObj = JSONFactoryUtil.createJSONObject(answers);
				} catch (Exception e) {
					e.printStackTrace();
				}
				if(ansObj.has(termName)) {
					for(int l = 0; l < values.length; l++) {
						if(Validator.isNotNull(ansObj.getJSONArray(termName))) {
							for(int m = 0; m < ansObj.getJSONArray(termName).length(); m++) {
								if(values[l].equals(ansObj.getJSONArray(termName).getString(m))) {
									valueCounts[l]++;
								}
							}
						}
					}
				}else {
					
				}
			}
			renderRequest.setAttribute("datas", datas);
			renderRequest.setAttribute("values", valueCounts);
			
			return ECRFUserJspPaths.JSP_DIALOG_CRF_DATA_GRAPH;
		}else {
			return null;
		}
		
	}
	
	private Log _log = LogFactoryUtil.getLog(DialogGraphRenderCommand.class);
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
}
