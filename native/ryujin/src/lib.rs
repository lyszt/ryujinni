use pyo3::prelude::*;

#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
    a + b
}


// Example of python usage 
// /// A simple function to add two numbers
// #[pyfunction]
// fn add(left: usize, right: usize) -> usize {
//     left + right
// }

// /// A Python module implemented in Rust.
// #[pymodule]
// fn my_rust_module(_py: Python, m: &PyModule) -> PyResult<()> {
//     m.add_function(wrap_pyfunction!(add, m)?)?;
//     Ok(())
// }


rustler::init!("Elixir.Ryujin");
