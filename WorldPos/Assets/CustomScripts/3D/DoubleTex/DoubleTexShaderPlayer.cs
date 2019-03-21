using UnityEngine;

public class DoubleTexShaderPlayer : MonoBehaviour {

    [SerializeField]
    private Material m;

    private readonly string _TargetPosID = "_TargetPos";

    private void Start() {
        var radius = m.GetFloat("_Radius");

        //割り算重いので、逆数を事前に計算しておく
        m.SetFloat("_refRadius", 1f / radius);
    }

    private void Update() {
        Shader.SetGlobalVector(_TargetPosID, transform.position);
    }
}
