
-- Copyright (C) Miracle
-- Copyright (C) OpenWAF

local _M = {
    _VERSION = "0.0.1"
}

local cjson                = require "cjson"
local twaf_func            = require "lib.twaf.inc.twaf_func"

local modules_name         = "twaf_attack_response"
local ngx_var              = ngx.var
local ngx_re_find          = ngx.re.find
local ngx_header           = ngx.header

local rsp_detail = [[
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta charset="utf-8">
<title>Web WAF</title>
<style>
body{ background:#eff1f0; font-family: microsoft yahei; color:#969696; font-size:12px;}
.online-desc-con { text-align:center; }
.r-tip01 { color: #969696; font-size: 16px; display: block; text-align: center; width: 400px; height: 36px; padding: 0 10px; overflow: hidden; text-overflow: ellipsis; margin: 0 auto; }
.r-tip02 { color: #b1b0b0; font-size: 12px; display: block; margin-top: 20px; margin-bottom: 20px; }
.r-tip02 a:visited { text-decoration: underline; color: #0088CC; }
.r-tip02 a:link { text-decoration: underline; color: #0088CC; }
img { border: 0; }
</style>
<style type="text/css"></style><style id="style-1-cropbar-clipper">
.en-markup-crop-options {
    top: 18px !important;
    left: 50% !important;
    margin-left: -100px !important;
    width: 200px !important;
    border: 2px rgba(255,255,255,.38) solid !important;
    border-radius: 4px !important;
}

.en-markup-crop-options div div:first-of-type {
    margin-left: 0px !important;
}
</style></head>
<body>
<div class="online-desc-con" style="width:550px;padding-top:15px;margin:34px auto;">
    <a id="official_site"><img alt="Web WAF" style="margin: 0 auto 17px auto;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAG4AAABuCAYAAAGxXBZtAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RDMwMzQxQUY2NDVEMTFFMjkxQzRFMDgyREMzQjIyNzMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RDMwMzQxQjA2NDVEMTFFMjkxQzRFMDgyREMzQjIyNzMiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpEMzAzNDFBRDY0NUQxMUUyOTFDNEUwODJEQzNCMjI3MyIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpEMzAzNDFBRTY0NUQxMUUyOTFDNEUwODJEQzNCMjI3MyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PvX1efcAACeISURBVHjalFI9TwJBEH17OSPERE3AyoaESkr/AxRySgIYExKhAKSk1VDQaUdoKNCj40hAYogChWiM/8CGRApCR0GllUrubmUXb5WPxk3mdjMz783cmyH+oh//Oc2TJr9l9umk2viiJneEa2EKsgjQP3U0jhtklUg8V7YCypWyYdu0vVVDVZimuQCMNCIIX09IMaUVQAaqBCowDGNpi1pAw+B9ANTAwRy4XwtS7UADpZQntV5bKHfLkFYk3mLBX4BzzQnXuovHe6PeuWQxMhCz7FMWyo6CSrACalLINhnpx7SIl/fLyDxnzmQiEQG0zrJ2/8b5P5KfmkIQiqXizPtk06AzjA67A7F2TAii6zqit9GFihLoLyOz1G5qpgozJpL1HutjHiNscyajoIQQqD5VgOL3cbjtbvQ/+ij5SjP++mF9m4/j7uiGsJF0R114tjw8QfWqYGSWmhaITOc/FOOYsJDcSw6JTkIks9bYrRs69zMQKyI2x1vcg3Kp8NbzofxF8iF5Oq8qa2+SM7R2+lsAMVIld/jN9/vMxsPGg00DyCsgGiN3gLITUBPD8oDlWG0C5QwhBqEXQKYkJB5BWWpl4H92FnYGUO6ABQw6Bsm9Y3gnAbSNFe5UULDP854HD/aw5aEMrFxs4FAVZxVnmOAzAZKSgDkIaPMvkLOZ2AXY4VkKhKM3RTOsjFjFsMQPmK2YmRhe/3sNFkOOT0giB9qGnoDR0yWyGOcvTobuQ91PmZDTJMwAZDZ6uvXW8GY4+/ysOAs2G2C5Y4HnAjCdsD0BrmbZxaUMEwImnmVi+MvwP39fPtzEfod+FFsStiUwzHOfB5dn42VnUBJSMmf68ekH08efH+Ge52PjY+Bn5wdrTNqRxLAiaAVc7trLa3BDwUlOQ04j+8HnB1NAOQIfACX0zWHrGEEpBxw4kz37pppImBwFSRx5cAQj8uPWx4E1AeOPHcVGZMAhyIERFy4KLo+2nN8ij5zIAQKIqNzByMy4h5WT1ZmJhYkBW/Xw7+8/hr8//v7+++svG67cBE84MAYoZ4EALJ8Grwj+D7QIrnB1yGqctQMTExND2tY01g8/PvyHlbAybDI5EwImTGWHFr8Y+R9mIajIAtGsTKwMi/wWMZADTj87zdB3qg/MNhDUP9TsWm+PYSGwZvnIwsnCB06MwBxLDZCzPYfh3a93DP+BVcXaiLWMcAuZ2Zn3snKxOsFyODJo2N/AcPvzbRQxHVEdhiuvrmCNT3T9Rx4eYZh+cTrcUnAcwixb7LMYsyCAVkggOWQQsykGXEwRqgmtZK0Ypp2fBkp4DH/+/ZnExMTCyIBekSNjWAWIIY4DYDMjQDEALBe7JjaTBVkvPoNiN8ditFuQU+20M9MYTr46idWMC88ugGkFAYVPTP///sco+pBxtU01JHUBWyXIGFZvgvDP3z/BlsVqx2I14+Hvh2Az2t3aK8GZ5NfnX+BwTdyRiDVIQKWiDI8M1qADlZppu9PAKdtRxhFDb/SaaLB6BzmHx0BqFko+hOXBHL1sBkMJI6xBe+XdFYb+M4iiGpSYfv36hVUtqIkBAlXWVeeNpIyMsGb85C0Zz199eyUBYguwCDD0OPaQlPeuv7rO0HuxF7ne5wCWNj9xljQwCVBuAdW46MHI+ZOTwVHRkYGNmY3h7LOzDPc+3gVXPsgA2Uc4izZCAFRwr09YP2nCiQnBF15cEPvz/w+jkqDSxxTDlDuKgopzge2lWfiaQjAAEIAW8w1pKooC+Nne25v5L78YlIOoCKJ/UEIKCyxBhqZOxShpzlBEjEAx/VATv4WfBL9IIcgky7QxbIjh0A8J4deCsD8QRjCsZTZC2r+nrnvu23u+be+9TaEjQ3jce8+95557zu+cPbPUXkWukM1gvJHNYsKMkQUR1pNNvBPdAT7E15EA4dFaSDUtEdNwhOEiiM+aOZKENRKD8fcSywpj1PhwsnmyX9qp7O4UT2Ydr90kWVsizLpTddB0ukk1+viDfujydtGTR7Oijvpn9Y6ZWzMpZkjxyqoJawx3SoH6eAW0nm/N+H74GA92j10wLzml+4ZbJz9Zgo0qn9RKiqYbpvekiL4ZnUFCZzwlEkJi2RMXy1j1EJZxKDgBA7AaOqf7iYkaU0/VU2ssRRmXx/Xgf2eNUzMzZCqiQoZj4N2PlTvSnRF0iJBTcUoZGSW8FYYH8/dhLbRGHjhDd0xdfotE++g23DzXBA1nG1LmLX1dgtH3o9L96eOsoqoI+b/tVRv4d34CfWtEUfelbsHlDQwYcjhwr7rpOOdbZ8LcsmNl0v0hgrJkcm66xIpuf+1EZpEmeQ2TwQQ+3geNk41ePWtk/fix1FSqjA1xN94vNgxaBoXvbIwgqUGfTXPahbv/NUai2VmRopT6CjIMy8hDkda0xrEiI6ZbLNPnoK1Mahapy9SnKXj+cbeoxjucqJ1QLA018yJOpLHx24Kqg+BmEqhL1t6QjyOJVH0NVEbKI9q6wJaV0sByU3lar7PPCsHXfMScMt/zwSNZA5XNadGu7YxNU9k9bw/FhhHLiOJ812cXHf+4+tGyYMb4SQeWBxQXRpZUkl5vL/yOBaDAWAAHyJ/ShsTgXphzqJyGKz4ogKtv06cayeV9K7zDltkWbJpAHpcHQ2VDinNuzwpOU3K45DumNKpsmzCEWNKIoKkkokJ0EozmDrMDhq8MK9cNL5ppLEXpu9x3NCVTi4QsNtX2K+0z7RDLjYnAOk+ydWVKpsb+g7wfsR+xuWySonHr+BtUpMoguIN4X1jqIIxZxtIq6V/oB7/Ov9skuO56TV7kVTmDqGJ451zn3/XgenYC0AR5KC4spo93I7QBi18WST4z0PtL6vFhVB9JRjlNImY4PeTnH4yGtkOGTExIlCwS3qxQI2JNAkUvDfwKcJE/ER1ZyNxxsWOlKLdok1Y7xoJwzcmaVfLdS37Z4UBYl6woWf4JQK3VxzRxhvGnBy0tIpbhpBMYE8uyGBcnyIdOCJtKhCEO5khrmCXExohzTRaESASN/6h/oMlCnTFMOv+gBgyCkBEHK2bsDzs1bpkBJBI3oMyQiLJ+Ukq7972W213px10Bkz3J5XqX3nvv0+fz93u6Er1+JAqNOnR8hbqAyIV8SuZXT8Yno8zpTmHYJ9B5AB3n0O2epWAJv+1+iJKMiv0Q6m0FOEX6YjRYSrbnoGYEGK/wnfwbVrtVHuqii5RbCIQFoeFSNyPWtK8BdZtf42YuUOndnrAd8qX5JNnvq1XCP4TFYYH+P/uhY7gDXtleUdkXk8mECE8qXDLhKqEM8x3ztnmXw+4QIUvNMlAdj/C730Vu6Us55NtCVDOsZN3woVD1jmpIk6QtS/9OBiZSrqq3CsZmxnySo28JJA/VJZe3LUm5PVcLRHwR37IAqeiCEi5aOAJWWrCFL+kvgX5SzyzSKF4lfMlk02ffxnNWbq9mnxEpFkW3lFgohiv5V5bNQlxl3DgO1T9VL7KkYrOivPT94u+DKoeUiRBECWwkZ05vXYtvBG7aX6N0P+mGluEWBmCIIWLM1z//LsqvcihlJyMMPEpnXPI25kH55vKQNzLrmAXdUx30Pu2F8X/GgOciIDMxE3KTcyEtIS30uCQIkN2SMa0463S1l7UTi5RDCgmRYla6YqoMFWRIMgK+5OLPF+Ge4R5gjpqHXkiva5zEA9dIQDqPz07YvWEPKDOUAR+T35KTCYiiTRz8Oa1cK2CUAtTTMBTD7FJ6XHrQ+JqZnyH7IbpsWbcFdm3YRaJq70ke5gB81kOeO3mQeyB3FQbh/PCg72/5tIWx5lz4HF/7SDsi3yp/l/DQJue8Y+xAygHOriJ7T0aO/k9knoDUdakk04zn7YxYXYFcdCH3AuMa4aoUzFi4f6OIMMZ8u35nfcgZcbkzKZv14lfHkx02P5JP1ckfR+40EZhCog/7sEjXSFmzdAxLuCD49zmFIXu2MGt9FuPZrifdbxM8j6//30UaK2VcG4yG1eFUHPCW7lp6gx4mpicCdhuHPzhMpnF/ovtLB6MvRznvZco8xbiOEcXYwnHNwwvQrWe2myGSH8nadRbkmekZefj9LkrxRzKPkEnGnzwYux9SDPcM9eB/AFDXOUk5k4Snrgwwpku/1LL29VM7T3HKgIHWUusb4dGL36j4VW5TstqDE1mIUY7Qs4pUxQjpHw6bI4e+QQw/npufs95wc37zklP8oY5DcH/6ARkeeMPaYi1YrVZWzx7UHmTwDlKx9CU6lbj/MuNwIog/zyDtTg6cxONx1ha8tvca7N+4n7PlzujOkOPeMKF7c9kJ2eQ0FivG5r21d2oZ7ojvnc87r0EfrYzeMlocrbXz7IyGrfHjRtbxR7Vt/Sow2o0+Yw7zxHhQXtFZAYTwP/QuDBOCpkgDFouF9XsqOyvBJrQx3PFm6c0+jNZ8ooK1sWvPmpymOvq91DdT4djWY5xdreFhAwy+GFzUQ9Iz86bYTVCXXcdJKZzEylrL8P8CvRXDHExBQDyXf70oAqFum/eipzNPQ2J0YkiAs2+iD1qHWoFAyBmPhjAFYTabOa91tPMozInmGD9QnCjOpC5U1yBUfpk1Eq/8QfXruGk83fsFJe+UQEFKwWsr0NhSijYFCNYImGgDWauttO2ukBf2UcgciqpHZTCYDOt9stfSL6jJ3nL3lMe7j4OZZ6LYcS+aYyBKEPUJspZxSQQRhYCHu8s1f2iaA21IQkhAmaaEJHESJ8t0DXVB2+M2PMelBhjeErcKuV+BeoAeV0tiv/zJ71ODX9bfrf8GIbUVbUyz4rP+rtpRhSt7EVLEERT5B+RQQoH8CAverri9u/Vxq7p9uF3qcDmIUNZJeSNluubDmiGxUKxDl2cLrxYGVSYQ4/yvANRcC1BU5xU+e+8+gAXXWEB28QGo9TEtBIslrVFADCqypNaBaYyMkYSMjKOhOgw27ThIEjEqI04wGAiYkEhqFZMGU6YjPoMygPiYFCmiEQjgA4ouBAT21f9csuu9dx/cXRaNx9kBl/v67n/+/7y+8487dWbck0V2wFEuv5sIVpD48DwloYxk7hhJAGmUeEqQTc188HfiBxrJ3EKKiZEW0wMiSrQLawyufhSxiwC9SlTzU1pC0yLx40KywNXEnSxEGcR7yTDo9CDSUeVanXY1pkOeKjgCopg4rOvRaXUq48VLDCHHigBVS3SSYcMwgTqsn02O+N5l4EYrhKCoP1b/hajUTjMoF6fPschC1FVM7nHLOGwkrqh2AplbVnmNbFPAf1aHRo6sXjICaIDMHYqfd2ELpt0xNRg1PYpxuq1VePBzves6VNysgOr2aqsjymTkaJCRpxxK/nvyp8V/KnYoOyzYiJPRSiSLwBFbpSsEtCNyByjlSofT7ggUUw+H/3OYKWfZiuJFWtAeSyqTCh05QeDii9VHxB6SRHZm1yTTFNNg70t7mYKEq9Ty0p1LsKd6j9WsNPZWTaQnenzy6iePRgM3qimIL46vlsilFsCwBFzyhxJ4P+p90OucJ/BZpAzIqM+fPJ9hIMYExlioKrpmGqNmIOdMjnJU58LeH5cVxZ0hNukF/qIR7h/OpAEkIIHxEgS5PmQ9E8DyAWK9sKqjqrO0vtTbKXDLilZmEwMcyQe29XdbIW1B2hOr0ckoGTOK2LjBFgR4tPEfXUQVRQ6BiylcOZfMsW38FRHnVtjksCfuYuEofvbyZwwVigNQKoaEzxO0DoEjq+J1/hzLjs4GlYfKZXPLmbmYvyIfpJSUo6IGqYHOOp39nSBwyw+pG5jlniVrg9fCdM/p8LQFQZa8XGKxutbcrflVi6Yj1C44Mr/8yGo0j23HvD28ITYwFn4ugiNYHFdsEXKlnUirs+t+kUnaxp9necvyxlQLb+pqgpM3TsK3Ld+SsFbPlJsiAiNhUeAipg/YGcE0YLR/NJzqOGX+Tkfr6Gud13aGqELetjDiZNRUUi9pB3t13PCbDbDIf5Hgm2JnSWVzJdNoBTTxKMi8ZUpk7CjBSnkY9CIInxIOEUERDtXJ1/xzDSf6MJKls2xtGW0xcsRn/I6/7AsBlliaSAAAB4jYUywoCjCVh5kCyINLUFdXB8aaEdCYBT+65qjde6f/Nh321rFaeyRA9Q31bfKSeX3weM6JGHCTOPnBsFRhYYVcTFbXEY4grrDW4ji5RA7xs+Ih1C/Uvn9JzsfFDL0QrJLSNG333qHKUI7bhy8s82TmDs7IkQm5kT9qC5ULnTLUyJaNDoiGpUFLwVfuy/RWmPq0i68UObVC2nUPg+LhROvjVMPtvtvPkR84UD0jiiGhc9grZODEQKceAj0JU6MICr+1bDycmldCXuGAw6mhGdRsV7gp0ihmDoi5JC52I78DyUen6t6usH26R1qOeh++fHgVo5EiDDt5Kunv4S+84M+7kauK/UKuZ/qEK7nF/rOtZxmyG0XRolXPesF/xZwVnP/riNUjP6aSkaOW8iPqZ03m+MzhJ64YS4Z7fHCs5lzvuWOaN6M1DzmjlkKOQ7toZkGNKGIIRSzdLPaBKk/VM6maRra9G0E3DR0jBSc4pGXPJjiDkeMFEVGgncP6lpfZ6zYaxsT7ehrcLxvijuC62eCw7cJZ+ajmI7sRhI+XD6Q8b58/WXi10Nm8GcfmEukXkzfThE6J6fsWTYuzqXU4d/ecXT7K637J8KLqRbvXKbhS4BQXzUqSuENMdPUcBuCmb5p7mp1WBeahRK5TM6FqPqAdAHYv90/nNCE96sufy6JQcrXE3BLjiGAgzBntkfdRj7tLNPFVybSoCPkgR8VVLlVlW6V55JN+ncQ43kKe4asGbgo+QBGgQcyUqYOXLRW3hfcLbQ7b7BJqL3Yymo0wuV7cL+MEn/tw6CE3DJodj60kBgacyCCqZP/R1HspVFKfTx0TsCudV6Bb320eta3hWwWT2u703bFg7EUERdw1R+I6rTaJf5JWrxWsmgv8FoBCqhCgkpZqSWIvyK3PNdf53Gl3mO83X/C9s05lcaj3YGD06KAZnF5ruMtXTVsNsrZkX9Q+h9UTV7lN/970eKUj5x+KPwRDQ0MCQ0gj9Om5BLrk0OT/kh/HzeCY2pdBtI99EPItHTUJB6LzBB97/8f7kFqRCuwmqAPLDzhEcEM6Il8lY2fH3rRIyg4/Gt7Cf/Nbzm1xzN+ReMC7C98d9biyhjJIP5vOAfbO4ndATskdGvX2fi6fOswvDOfaGxbgDFoD6jtnuwfc7Kyxu9GhnD5WVrN+n2X1gWrbayHpeBKT82Cn7N+LeA+myqc6tFFHSlmKxahtW7ytAZXCajpd06tZyx+9PfV7OCRtIeLv6Q/7o/ZbfN/woIF5ILarVBBbACp3lc2Ny6zJ/ov7Rxh8LImbFYesh0ROmp1jvMnouYncIvkXwx2ZHBVPiSfTu84pO7FrEO7eTNsaraMdStdf7rgMl7vquSwK8vZfC30NCW89HHfQWk18zfF17X26Pn/+w9pqqh9NBsk/3FEK+wUw0k9/IR3ERrHNXaVsyQ+aH+Cvp9622Kup9I+l573EbhGCC/7xR1YbjSKuOmIBAjnPT0Mauxph5/mdIJvABfZm6JvXY2bGxMpEVKvggr92UEvxp9qgfpBRUSM82dzkN03fQHZVtgWwYJ/g+wRYLgKzdp5NcBXrvjaGK8N9+d8byL+UkynMm3wS8taJt+DYrWOA24yyZYrXlN7tkdu/IMBsRrd22Qx/W5zRpZ6htkqJyLmaA3+uHL/CP+5QhNtJ9Mv6gV/pJV7/w9zludi0mmY3vhRCsiHOqWxzxeZB/hw0iR/tB5kRmUBT9JhBXWi9AAdrD4J0ghSskXpwd84NCzYgFTmTSWiNlUFkko3/2th7r/+el60HQ3bPqhmrQD1X7VDQ2fqwFQrrCqGtt40BZSvNsGvJrrqZv5iZQX49Y87WuQocMxebK3KKrhaN6pfph/WgH9JBkGIGBDwXwGyvzLh5+mHo7OtkyskYh2FdD0nb9vImPh4+A/kr82t+Sodw7MeYWHt89jeGW+QiGbsv7P6+trPWZgcFPjR+2g3t0P4/Kz117sS0uLvZvTcFlDEvNq/aV+6bT57jc4dzOs5ynNFDKH+jXPlh3YcXT7ecDnDlYkJ8XO3ul3ZfUnopv44riNtl79hx2TIEI3hy4zsEZCABKeno7fggry4vobmneZIz1xOLxIaEeQk3V89bjTZrB7n2hbG+JJey09EhLn+9HC3tuls9t5Kq2qpUN3puTLz34z2Pfm2/RGvQ0mRUdJPcJz2appjWFzw5+MGSoCXdtIi+Rs45ov5YfZGTFhcg9kbu/wK0dyVQUZxJuPqYAzlFCSCCCgaD+vBA1wUV3Ki4Ubyeqy9oVExC1s0+TfI8E99zo5s1xiOHx2bFbBLdeCXmeMQca3Q94hURTYwalGtQR7w4JRwzzPT+9c/hMNDN4HTDGK28dhglM939ddVfVX/VV/dj6T2uN5HEGPchRigKlz3ycwTaHWKTgsirv/WJtFl1DNWxP6GCLMm3yOst4mBhAklH1uh88jPeWIwoTG1xMVLgSD7pHgpOCFHlPxFAxhJwEpE2wpEezlbKYl9JHeiNnCMrCqDlQccih67ULRbuxre2Vnea4bQe5L2BHIdJJPYZeb/LOZLyBPEE4DpRnimWSSfmKJC11SEhMKwVEHc37BtgyjR+3zippiYQjiARwggC3D+xgAsnPrACW0neb6qvr8ew9tqDBlwoAWkZyzNpDMeqGgDlKRUVNg3mbPtirKU8TQA/oqELWBO7gNZkmQWTlvHaWVVbtQAz3x4FXHONgk21wjhLyuaUBJZjNrM815MSn8kIFJaVYH0ZOuV+Gj/w1fjSVIhz9uBO3R2orKuku8bI4WDnGGspoA49RwRIzigYp6l59TSspGjHeemNxvrUT9I++d7Vj2zCb3fp3iqmcQSsGKJNOwlQsZgdsIPVQuka0BUSOifQykP82ZluxS3FsrYT2R4iXZkOzlw/A8euHgNdua7FQNYJhjCBFQ5P2DoBfHlfPTGrT3z01Ec/K2IUmvMqW6JxxIdnyEWsIBexiFNxDG0RbAFYCMy46HEwOHwwNVVtUf/nDCo6M0evHIXMS5mugWlbJvHc6wWa4g73Dd9eeLvwKeJBCnJpnCzAEe3yJdqVyanZYZR828X2x/ba9pDaOxWGdRlm74jwZMH+NwQTKR13nt8JZbVlLiBoJfCsN0GwNkQX7h8+YMnIJSVtCtzIjNEI2HecmhuEpsKV1k5svpjzuzkQ0yGmRTs6HhlQchzt2txwagPcrr7tUtYCNTBIE3QjPiK+76xBs6636ho3ctNohniF/+HU/DRXAEN2kKm9p8LY6LH2Cvn7HTTbNfQI7AHrk9fTvHFmTibsuLCDlu+I5dJwE7nEXBKcmZtZnHM7J+dyZXG/CL/QWsXXuOTNYyYTDdtFDqY5k+il8oJFCYuodnm6GZTTnKIWrjq+Cmrqa5o3oQYzjIkes+mv8c/NVsRUErOo4VTsSaJlsWLjveypCuKSL0taBp28O7WZc9HmoSBZC5F0ftnhZU0yTDkCiKFEkKbjnUXDFsfFdOyeKxtwRMsSiIZ9Tw7Jbn40iQsSFkDfoL4PLGBNAXim+DSs+WEt3awVxc9EtU9IH5D+5sReKfPdBo6sZYs5Df86XcskXHtsF39p0EuyNff/5kwoWQPXHlkLWTezJEMIdF5GRSafnh3/F2zbEW2e5qLHRot/mYrN4LWqhbgLLQYaxlu4STwmcozHaBluaeaX5EN5TTk123JsYLsreG/iw+OhV8decKjoUJNLjY1yI680P7TgVkHa0G5DkWq7pkUaR2Ky98l6NktqPcN001sj3wI1o26Vi0eG68LSQigoLbAf+ko9CIzZYefAKZ1m3wHAzP/dSUU+Km+ICOhCCclwH7tL+y7kfQSoOJXyD5bZAHO/ngt3zHfE1z1iuQYExxW/8vgS5FC45hJwRNNW8xp+vhRoyHuC9CByeIs4PQsBQS2hgJQVQHFlMWApCIY5DQCx7Ri4u3MgWCliBYefza0HMmrW/K/ng96gl3RahkUMK5o7ZC7Snt+UBI6ANZXTcts4XnxwRIhPCKwZvgYYwf0s8d/2L4VL5bnyAaKInXMCmQA6EmncB6a7FY/iA7nwm4Vwte6q6Pcib05an7TT43uNjweHqpQGATjxGEOI57i1OfMoF2iWk2ehpTlNFKz2xNE8kQGRENU+ijZ7B/sE380TkuO97Pfo/C63O3AZp4dJJhpvfABW/nElzP58NlSxVU1+L2Kx5cyWfnFhces7B3T+cyPgaFSvYreQX+SkTmrp0KUWkyJTgaXY5+AMABweGdk+kqbJUGy0AGK7A85ltlQbXJj25q7T4a42Lx+xnK55TZF4Uix4YNYfXzf5jSdW/RccGySswI1meS5ZKn2V2isVHtE+orxlIk9iTGAMHX3jx/tRQGxzDhx5HX4rgvuJmBIUC6UQk9yyvPYH8g7gnFYvO3B0P4lnLcRQEiYypXsKPBRlZFzPceAr+Iqbaqwyy/kSO22fcgSuBwFuqJSJHB893jJbTGZyq+bMkFKfLZeZlO0gVmZir4m03FYsA6Or1AXk3c6bTp1SK5oTm0sYDw4b/FAtFBZk9cYaaVGtIxgdKTqCLTlDeevWe5IUaNGB0aBltco8xYL03yvF5CGHUyW3ZiP/xaPkXusMOtEBTDm3crDDK461ItlDykzSWo+H0ioS1TGK5ivFzOXN6ptIax1tGy0kSW0XqA18eEdbSbBaDXcKxKTaWI3pms62wMFXylTaCnfaIjHr6W6/3OdnsXyC6DpnqDdgxtzbFsdVSH1YnanuoSq0ktQapasYtLwWvZca3rrQ5pI/Bohp3bWqVq62Juex/fx22HZ2m1tP9LNxz8L2Advd+oyNpzbC8WvHWy13irsdokkQchmB7QJxm6eCp9dkhmwC3gCxfsSckhzFTFZTKS/q6fKMW+W6uE6wrMXESw19a06wrA7Psal7o4Qpv3D9Arl2VvRedfXvintBl1lrtnufVOoRy7Uvll184MwWMs2cKs5ute8jrj6t1WRFgEOMYkNisZjzJwuBktn8OdE6SeO6//J+RU52RuwM2XYa5JSS6hJ4ce+LUM/WN4qp/DX+kNY/TXZt25u7t8EQQGfhGd40PGo4FnB+bxkMaBJMZpP5bakTOXntJBRVFMme8orwi4AViSuwcdhj0lLnb5yHlwhoZs7caL3xV/nDxtEbaRuk0WiU7T5g38Ix3THRMV/4O0kRSXqOpR2uVyz0SbRE2vwPooqSY3w+OP+BIjc31CcU1g1f5xJ5ltKy9cxWWHliJTDqxoW+QdogO2jurJtNScbJDAKa+KAf8mCbZ/afiX3WOy3vrbaTaFwVidjnSWkdcj9+mvupIjcM+cXffvxtWtoHbRC6Ia3bc18+B/uv7YdGxVHkfHDiyobRG2g5gdyg7Tq7CwrLCikHu5i2TXpsUr632hv5GeiEIt7RCzMZTevVKvVkE2MSpbLfk7+HPnk461QJmdt/Lp3eufbUWrc3awUXGL9rjDWw8shK0FXpaKsU61zLT/7X5+Oex1HBlExN7nUNqSmRwVETIM7TG+kfWfZk7JNY3/C6fb1r6PoSD6W2NlnjpblpZsy+UiYTp8Q4j+eWS3Cs6ubkzZRM6nzpeUW+Axsd1xxdYwesKaegm383WnrIk/9awoDnqmTrs+HdE+9K0rtoGa3x78P/jj12K8ChF513frqIuaw1MIYYskjqSOgiGkll/JxB6xcTwxMVubH45M8bOI+6x6/98JprLU0uCDoeG7LWQ7VQQ91uRyY/m7Tj28Gria/SUbjkQYY6Qf7M0cGCg3RdEyMaovdAYM2rRq3K1vLaHeRtA3bRRsCgo2IymEj4Dj14DZ9LXkXdvQ8vfIibezC953TF1h7kqVuTuAb0VXpYlbUKqoxVLf6MS7cvwdYft8DlqitUuzC455jGgHnxXrA4fjH06NiDUp4qoWXUYmV/APvy91HzKFpoLDDC6uTVWZ38OiET7r8a/btYQay1JShErVXrzGCWJEpHsr+lg5YCWTyVj69qS+j6d6P6RvNhgMmyvtmpNkRuUrB3MLyc8DJ9RQ1TqrPoV8OvsGTvEiipKwG1r3gRsYpRmdY9se6HIO8gLAxa2yQ+Ur0DFDw1p/Hz8cuvNlWHNXdik6Imweio1pkYhQ0U6OF+W/DtPeURMejHcowpvaZQK4P0tEruROzJ2QM7ftoBKh9VI2I5p5Cj+p3R75xSc+oM8nab6Pm72mY184tnt5bWlU5v7iaRL4T5/eZDVGBUq7nydeY6+KrwK/iu8Dta3i0muHZhwRPSWqNzhWAp3WCZV5IHKw6uACNjbERx6OxfkAD76pzfz8E2q7kahj0nWytx6u4ZsbVCbXa9UN9s+tdP7Qcv9HmhRcPC5RA0hyqVZX4UAorDW1EQIIy/8GiNPT4kBVx9eDVUGCuoWZSqMOBZ3vTasNdOd+/QHb3H2QQ0mgiRvQf8+W9e2Hal8spUV0wUz/CQ3jMd4jrFwYMgp/SnYOOJjWBi6omGaaTNOHl+RnSjNJXIJbaMAHawgSVRonl/6iczvNt5eZ8jTkJXVy+qT0AfeKbvM3Yt+K0IEnwj5WbW1SyathLLgDjFiOXL/7D8Zy+VF2bvlxPQGpkBReky3jjyZmhuee6PBEDXS5zJ+Qx5ZAhM6T3lvgURwfr47MewP38/DS8oV7gLrBNhPmGVBLCz/lp/NIvzCWCiMYfiPCcomb9kBh7THzuRV5r3aEu8PPToQlWhMCF6AvQP639PE01aQzD9hiMudp/bTam97fyvrkx/x3204NhbCwcv/IUE0z+Sv3kZscd/alOCGufPfP/0+5v2Fe57mnh4LW4FxWppH8EbEsIG0wJRbOlqC7ledZ1yQ2MuETdUOTULnJYXzXI06WGzatPMPjMvjuo+CnvbMPuxGZxS6J4EnF0Kywof3X1h9+cn9Sd7Cm7sliKYZoMJfDhfiG4fDdEdo2mDYbh/+D2bWjR1qDm4D4aZlYu3L1KAsEafw2SzdVLqPcSHQmJEoj59QHoB0S6c0IGDJorEft8jgXOUW7/e6vfZL5/9+1DRodh70cTmzO1dklBLN2njvSGGdrcCc5ew1CUz56JmJUcmX54WO+2KilMVWrMdLpGvKQacrDEW3izyRGfOyuxw7sa5eXty96SdKT4TYsIxzPeRcMAJ/UL73UjtnVpE4lRMnuKwrA9TMlJaPInvvqD2tWmF9QJfIUC+YgUyqMpQNflA4YFnjl452i2/LD+A/KZHgMkxnDmmY0xpUpek60O6DClRsapKvN/k+IJcx822Oi/PItO2dqTgQcDEuvckAmhSlj4rkaxBHfLK8/z1FXofo2CU1dRiUjfMP6yqe0D3iseCHqsY2GlgubfaG+sXz5LjCDn+l7I55Y4SO/P3qnH3Bwu6A3k2vmY+nYkLAya9o6yv6HoiAzoSZmPhCnosmBi07WrghprB6oJj1TZu7iEjOk7BQtqDfHwd+95Ys41cu7XkXoH7P65tshCWRFV5AAAAAElFTkSuQmCC"></a>
    <span class="r-tip01">Protected by Web WAF</span>
    <span>{{category}}</span>
    <br>
    <span>UNIQUE_ID: {{UNIQUE_ID}}</span>
    <br>
    <span>TIME: {{TIME}}</span>
    <hr>
    <center>Your IP: {{REMOTE_ADDR}}, Server: {{URL}}</center><br />
    <img alt="" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACIAAAAiCAYAAAFNQDtUAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NTREMTRFODA2NDVFMTFFMjlBQ0RGNkFCNDFGREYwNDciIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NTREMTRFODE2NDVFMTFFMjlBQ0RGNkFCNDFGREYwNDciPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo1NEQxNEU3RTY0NUUxMUUyOUFDREY2QUI0MUZERjA0NyIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo1NEQxNEU3RjY0NUUxMUUyOUFDREY2QUI0MUZERjA0NyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PjwiMq0AAAlVSURBVHjaYjx27AQD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">
</div>
<div style="display:none;"></div>
</body></html>
]]

local rsp_no_detail = [[
{"msg":"something wrong","status":"success"}
]]
    
function _M.header_filter(self, _twaf)

    local tctx = _twaf:ctx()
    if not tctx then
        return true
    end
    
    local cf  = _twaf:get_config_param(modules_name)
    local gcf = _twaf:get_config_param("twaf_global")
    if not cf or not gcf then
        return true
    end
    
    if twaf_func:state(cf.state)       == false or
       twaf_func:state(gcf.simulation) == true  then
        return true
    end
    
	local modsec_notes = ngx_var.modsec_notes
	local attack_info  = ngx_var.twaf_attack_info
    
	if not modsec_notes and (not attack_info or #attack_info == 0) then
		return true
	end
    
    if not tctx[modules_name] then
        tctx[modules_name] = {}
    end
    
    tctx[modules_name]["state"] = true
    tctx[modules_name]["gcf"]   = gcf
    tctx[modules_name]["cf"]    = cf
    
    local content_length = ngx_header['Content-Length']
    if content_length then
        ngx_header['Content-Length'] = nil
    end
    
    return true
end

function _M.body_filter(self, _twaf)

    local tctx = _twaf:ctx() or {}
    local ctx  =  tctx[modules_name]
    if not ctx or not ctx.state then
        return true
    end
    
	local attack_info  = ngx_var.twaf_attack_info
	if ngx.arg[2] ~= true then
        ngx.arg[1] = nil
        return
    end
    
    local cf  = ctx.cf
	local buf = cf.format
	
	if buf ~= nil then
	    local file = io.open(buf)
        buf = file:read("*a")
	    file:close()
	end
    
    local format_args      = {}
    local request          = tctx.request
    
    local func = function(m)
        return request[m] or format_args[m] or "-"
    end
    
    if twaf_func:state(cf.detail_state) == false then
		if buf == nil then
		    buf = rsp_no_detail
		end
        
        buf = buf:gsub("{{(.-)}}", func)
		ngx.arg[1] = buf
        return
    end
    
	format_args["category"]  = ""
    
	if #attack_info ~= 0 then
        local a = twaf_func:string_split(attack_info, ";")
        for _, v in pairs(a) do
            if not format_args["category"]:find(v) then
                format_args["category"] = format_args["category"] .. v .. ";"
            end
        end
	end
    
	format_args["category"] = format_args["category"]:sub(1, -2)
    
	if buf ~= nil then
	    if type(cf.format_args_add) == "table" then
	        for k, v in pairs(cf.format_args_add) do
		        format_args[k] = v
            end
        end
    else
	    buf = rsp_detail
	end
    
    buf = buf:gsub("{{(.-)}}", func)
    
    ngx.arg[1] = buf
end

return _M