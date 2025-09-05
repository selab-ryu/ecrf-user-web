package ecrf.user.teeth.command.resource;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCResourceCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import java.text.SimpleDateFormat;
import java.util.List;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.teeth.constants.ECRFTeethPortletKeys;
import teeth.model.TreatmentHistory;
import teeth.service.TreatmentHistoryLocalServiceUtil;

@Component(
    property = {
        "javax.portlet.name=" + ECRFTeethPortletKeys.ECRFTEETH,
        "mvc.command.name=/teeth/getHistory"
    },
    service = MVCResourceCommand.class
)
public class GetTeethHistoryResourceCommand
    extends BaseMVCResourceCommand {

    private static final SimpleDateFormat _fmt =
        new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doServeResource(
        ResourceRequest resourceRequest,
        ResourceResponse resourceResponse)
    throws Exception {


        int teethNum = ParamUtil.getInteger(resourceRequest, "teethNum", -1);
        long patientID = 1001L; 

        List<TreatmentHistory> list =
            TreatmentHistoryLocalServiceUtil
                .getPatientTreatmentListByTeethNum(patientID, teethNum);

        // (3) JSON 諛곗뿴 �깮�꽦
        JSONArray jsonArray = JSONFactoryUtil.createJSONArray();

        for (TreatmentHistory th : list) {
            JSONObject obj = JSONFactoryUtil.createJSONObject();
            obj.put("treatmentDate", _fmt.format(th.getTreatmentDate()));
            obj.put("treatment",     th.getTreatment());
            obj.put("state",         th.getState()); 
            jsonArray.put(obj);
        }

        // (4) �쓳�떟
        resourceResponse.setContentType("application/json");
        resourceResponse.setCharacterEncoding("UTF-8");
        resourceResponse.getWriter().write(jsonArray.toString());
    }
}
